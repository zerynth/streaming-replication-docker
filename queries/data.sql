INSERT INTO data (time, v1, v2, v3)
SELECT
  time,
  random() AS v1,
  random()*100 AS v2,
  random()*1000 as v3
FROM generate_series(now() - interval '24 hour', now(), interval '1 second') AS g1(time)
