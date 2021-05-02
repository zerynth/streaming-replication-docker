FROM timescale/timescaledb:latest-pg13

ADD replication.sh /docker-entrypoint-initdb.d/
