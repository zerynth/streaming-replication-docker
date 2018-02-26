#! /bin/bash

docker rm timescale-primary timescale-replica
docker network rm timescale-replication

docker build -t timescale-primary .
docker build -t timescale-replica .

docker network create timescale-replication

docker run -d --name timescale-primary -p 5432:5432 --network timescale-replication \
--env-file primary.env timescale-primary

docker run -d --name timescale-replica -p 5433:5432 --network timescale-replication \
--env-file replica.env timescale-replica
