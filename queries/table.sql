CREATE TABLE data (
 time        TIMESTAMPTZ       NOT NULL,
 v1 DOUBLE PRECISION  NULL,
 v2 DOUBLE PRECISION  NULL,
 v3 DOUBLE PRECISION  NULL
);

SELECT create_hypertable('data', 'time');
