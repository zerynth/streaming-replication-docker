# Streaming Replication Container Setup for TimescaleDB

This repository creates a configurable streaming replication TimescaleDB cluster with 1 primary and 1 replica.
To learn more about streaming replication in PostgreSQL, take a look at the [TimescaleDB Streaming Replication Documentation][timescale-streamrep-docs].

The `Dockerfile` takes advantage of PostgreSQL's [init script hooks][https://docs.docker.com/samples/library/postgres/#arbitrary---user-notes] and runs
`replication.sh` after the database has been initialized to configure the replication settings. `replication.sh` uses the variables defined in
`primary.env` and `replica.env`, which are meant to be configured depending on your desired replication settings, credentials, and networking preferences.

## Running

The containers can either be created through regular `docker` commands or through `docker-compose` using the `docker-compose.yml` file.

### Run with Docker

`start_containers.sh` creates a Docker network bridge to connect the primary and replica then uses the `Dockerfile` to run `replication.sh` against both database
instances.

After ensuring the variables in `primary.env` and `replica.env` match your desired configuration, simply run:

```bash
./start_containers.sh
```

This will create 2 containers named `timescale-primary` and `timescale-replica`.

### Run with Docker Compose

`docker-compose.yml` retrieves the relevant environment variables from `primary.env` and `replica.env` then uses the `Dockerfile` to retrieve and
run `replication.sh`. To run with `docker-compose`, run:

```bash
docker-compose up
```

## Configuration

Configure various replication settings via the `primary.env` and `replica.env` files. Whether the replication is synchronous or asynchronous (and to what degree)
can be tuned using the `SYNCRHONOUS_COMMIT` variable in `primary.env`. The setting defaults to `off`, enabling fully asynchronous streaming replication. The other valid
values are `on`, `local`, `remote_write`, and `remote_apply`. Consult our [documentation][timescale-streamrep-docs] for further details.

[timescale-streamrep-docs][localhost/NA]
