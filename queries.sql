-- 0. Bonus Question
CREATE MATERIALIZED VIEW latest_dropoff AS
SELECT 
    taxi_zone.zone AS latest_dropoff_zone,
    trip_data.tpep_dropoff_datetime AS latest_dropoff_time
FROM taxi_zone
JOIN trip_data
ON trip_data.dolocationid = taxi_zone.location_id
WHERE trip_data.tpep_dropoff_datetime = (
    SELECT max(tpep_dropoff_datetime)
    FROM trip_data
);

-- 1. 
CREATE MATERIALIZED VIEW agg_trip_time AS
SELECT 
    z1.zone AS pickup_zone,
    z2.zone AS dropoff_zone,
    AVG(t.tpep_dropoff_datetime - t.tpep_pickup_datetime) AS avg_trip_time,
    MIN(t.tpep_dropoff_datetime - t.tpep_pickup_datetime) AS min_trip_time,
    MAX(t.tpep_dropoff_datetime - t.tpep_pickup_datetime) AS max_trip_time
FROM trip_data t
JOIN taxi_zone z1
ON t.pulocationid = z1.location_id
JOIN taxi_zone z2
ON t.dolocationid = z2.location_id
GROUP BY z1.zone, z2.zone;

SELECT pickup_zone, dropoff_zone
FROM agg_trip_time
WHERE avg_trip_time = (
    SELECT MAX(avg_trip_time)
    FROM agg_trip_time
);

-- 2.
CREATE MATERIALIZED VIEW agg_trip_data AS
SELECT 
    z1.zone AS pickup_zone,
    z2.zone AS dropoff_zone,
    COUNT(*) AS trips_amount,
    AVG(t.tpep_dropoff_datetime - t.tpep_pickup_datetime) AS avg_trip_time,
    MIN(t.tpep_dropoff_datetime - t.tpep_pickup_datetime) AS min_trip_time,
    MAX(t.tpep_dropoff_datetime - t.tpep_pickup_datetime) AS max_trip_time
FROM trip_data t
JOIN taxi_zone z1
ON t.pulocationid = z1.location_id
JOIN taxi_zone z2
ON t.dolocationid = z2.location_id
GROUP BY z1.zone, z2.zone;

SELECT pickup_zone, dropoff_zone, trips_amount
FROM agg_trip_data
WHERE avg_trip_time = (
    SELECT MAX(avg_trip_time)
    FROM agg_trip_data
);

-- 3.
CREATE MATERIALIZED VIEW latest_pickup_time AS
SELECT MAX(tpep_pickup_datetime) AS latest_pickup_time
FROM trip_data;

CREATE MATERIALIZED VIEW ... AS
SELECT 
    z.zone AS pickup_zone,
    COUNT(*) AS cnt
FROM trip_data t
JOIN latest_pickup_time lpt
    ON t.tpep_pickup_datetime > lpt.latest_pickup_time - interval '17 hours'
JOIN taxi_zone z
    ON t.PULocationID = z.location_id
GROUP BY z.zone
ORDER BY cnt DESC
LIMIT 10;