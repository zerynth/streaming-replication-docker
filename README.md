# Streaming Replication Container Setup for TimescaleDB

Use this repository to launch a streaming replication enabled TimescaleDB
cluster with 1 primary and 1 replica. It is based off of the `latest-pg10`
TimescaleDB docker image.

The `Dockerfile` takes advantage of PostgreSQL's [init script
hooks](https://docs.docker.com/samples/library/postgres/#how-to-extend-this-image)
and runs `replication.sh` after the database has been initialized to configure
the replication settings. `replication.sh` uses the variables defined in
`primary.env` and `replica.env`, which are meant to be configured depending on
your desired replication settings, credentials, and networking preferences.

**WARNING**: While `replication.sh` gets run as the `postgres` user since it is
part of a PostgreSQL entrypoint script, the current TimescaleDB image logs in as
root by default. Be careful if making changes through `docker exec` or similar
commands, as making permissions changes with `root` will likely break things for
the `postgres` user. We recommend either running `docker exec` with
`--user=postgres` or running `su postgres` inside of the interactive shell.

## Running

The containers can either be created through regular Docker commands or through
`Docker Swarm` / `Docker Compose` using the `stack.yml` file.

### Run with Docker

`start_containers.sh` creates a Docker network bridge to connect the primary and
replica then uses the `Dockerfile` to run `replication.sh` against both database
instances.

After ensuring the variables in `primary.env` and `replica.env` match your
desired configuration, simply run:

```bash
./start_containers.sh
```

This will create and run 2 replication-ready containers named
`timescale-primary` and `timescale-replica`.

### Run with Docker Swarm

Provided you already have a swarm intialized, you can deploy the stack using
`stack.yml` after building the image:

```bash
docker build -t timescale-replication .
docker stack deploy replication --compose-file stack.yml
```

`stack.yml` uses `primary.env` and `replica.env` for its environment variables,
so make changes in those files to tweak the settings.

**NOTE**: The `stack.yml` file sets the `REPLICATION_SUBNET` on the primary to
`10.0.0.0/24` by default, allowing all traffic within the service's internal
network to connect as the replica user. To tweak this ACL, change the
`REPLICATION_SUBNET` variable in `stack.yml`. Note, however, that the technique
we use for the regular Docker setup (using `getent` to resolve the Docker
hostname to an exact IP -- see `replication.sh`) does **not** work inside of
`Swarm`. The Docker hostname resolves to Docker's `service` IP, which points to
the same container, but the container itself connects from a separate internal
IP, which will render any `/32` subnet on the primary ineffective.

### Run with Docker Compose

To run with Docker Compose, run:

```bash
docker build -t timescale-replication .
docker-compose -f stack.yml up
```

**NOTE**: By default `stack.yml` sets the `REPLICATION_SUBNET` (used by `pg_hba`
to authorize IPs for replication) to ` 10.0.0.0/24` for compatibility with
`Docker Swarm` (see above).  Depending on your network configuration this may
not work with Docker Compose. Either overwrite it with an appropriate subnet
setting (`172.0.0.0/8` will allow all containers on the default Docker network
bridge to connect as replicas) or remove the variable altogether to force the
`replication.sh` to use the full IP of the replica, which should work with
Docker Compose, but will not work with Docker Swarm.

## Configuration

Configure various replication settings via the `primary.env` and `replica.env`
files. Whether the replication is synchronous or asynchronous (and to what
degree) can be tuned using the `SYNCRHONOUS_COMMIT` variable in `primary.env`.
The setting defaults to `off`, enabling fully asynchronous streaming
replication. The other valid values are `on`, `local`, `remote_write`, and
`remote_apply`. Consult our [documentation][timescale-streamrep-docs] for
further details about trade-offs (i.e., performance vs. lag time, etc).
