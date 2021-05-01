FROM timescale/timescaledb:latest-pg12

ADD replication.sh /docker-entrypoint-initdb.d/
