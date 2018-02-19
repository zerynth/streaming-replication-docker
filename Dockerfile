FROM timescale/timescaledb:latest

ADD replication.sh /docker-entrypoint-initdb.d/
