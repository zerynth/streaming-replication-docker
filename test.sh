#!/bin/bash

docker build -t timescale-replication .

docker-compose -f stack.yml down
docker-compose -f stack.yml up -d

echo "starting..."
sleep 5

echo "getting replica id..."
REPLICA=$(docker ps -q -f name=".*replica")

docker ps

echo "Creating tables..."
docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -f /queries/table.sql

echo "Inserting..."
docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -f /queries/data.sql

echo "Stopping replica..."
docker stop $REPLICA

echo "Inserting..."
docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -f /queries/data.sql

docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -c "select count(*) from data"

echo "Starting replica..."
docker restart $REPLICA

docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -c "select count(*) from data"

docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-replica -U postgres -d postgres -c "select count(*) from data"

echo "Writing to replica..."
# must fail
docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-replica -U postgres -d postgres -f /queries/data.sql


echo "Stopping replica..."
docker stop $REPLICA

echo "Writing a lot ..."
for i in {1..100}
   do
      echo "$i" 
    docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -f /queries/data.sql
done

echo "Starting replica..."
docker restart $REPLICA

docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-replica -U postgres -d postgres -c "select count(*) from data"

sleep 5

docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-replica -U postgres -d postgres -c "select count(*) from data"


docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-replica -U postgres -d postgres -c "SELECT pg_size_pretty( pg_total_relation_size('data') );"

docker run -it --network ztsdb -e PGPASSWORD=postgres  -v "$PWD/queries":/queries timescale-replication psql -h timescale-primary -U postgres -d postgres -c "select * from pg_stat_replication;"
