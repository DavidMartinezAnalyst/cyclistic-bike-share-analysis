/************************************************************
 * data_cleaning_queries.sql
 * Cyclistic Bike-Share Analysis
 * April–May 2025 • David Martinez
 *
 * This script:
 *   1) Renames & casts messy Q2/Q4 columns to match Q1/Q3
 *   2) Pads Q1 2020 with NULLs for missing fields
 *   3) UNIONs all quarters into a single view
 *   4) Casts trip_id to STRING for consistency
 *   5) Creates ride_length_min and day_of_week fields
 ************************************************************/

-- =======================================================
-- 1–5. Create full-year cleaned and unified ride log view
-- =======================================================

CREATE OR REPLACE VIEW `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_full_year_tbl` AS

-- Q1 2019
SELECT
  CAST(trip_id AS STRING) AS trip_id,
  start_time,
  end_time,
  bikeid,
  tripduration,
  from_station_id,
  from_station_name,
  to_station_id,
  to_station_name,
  usertype,
  gender,
  birthyear
FROM
  `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_2019_q1`

UNION ALL

-- Q2 2019 (messy column names)
SELECT
  CAST(`01 - Rental Details Rental ID` AS STRING) AS trip_id,
  `01 - Rental Details Local Start Time` AS start_time,
  `01 - Rental Details Local End Time` AS end_time,
  `01 - Rental Details Bike ID` AS bikeid,
  `01 - Rental Details Duration In Seconds Uncapped` AS tripduration,
  `03 - Rental Start Station ID` AS from_station_id,
  `03 - Rental Start Station Name` AS from_station_name,
  `02 - Rental End Station ID` AS to_station_id,
  `02 - Rental End Station Name` AS to_station_name,
  `User Type` AS usertype,
  gender,
  birthyear
FROM
  `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_2019_q2`

UNION ALL

-- Q3 2019
SELECT
  CAST(trip_id AS STRING) AS trip_id,
  start_time,
  end_time,
  bikeid,
  tripduration,
  from_station_id,
  from_station_name,
  to_station_id,
  to_station_name,
  usertype,
  gender,
  birthyear
FROM
  `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_2019_q3`

UNION ALL

-- Q4 2019
SELECT
  CAST(trip_id AS STRING) AS trip_id,
  start_time,
  end_time,
  bike_id AS bikeid,
  tripduration,
  from_station_id,
  from_station_name,
  to_station_id,
  to_station_name,
  usertype,
  gender,
  birthyear
FROM
  `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_2019_q4`

UNION ALL

-- Q1 2020 (has missing fields)
SELECT
  CAST(trip_id AS STRING) AS trip_id,
  start_time,
  end_time,
  NULL AS bikeid,
  NULL AS tripduration,
  NULL AS from_station_id,
  NULL AS from_station_name,
  NULL AS to_station_id,
  NULL AS to_station_name,
  usertype,
  NULL AS gender,
  NULL AS birthyear
FROM
  `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_2020_q1`;


-- =======================================================
-- 6. Enrichment: Add derived metrics to a new core view
-- =======================================================

CREATE OR REPLACE VIEW `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_core_metrics` AS
SELECT
  *,
  TIMESTAMP_DIFF(end_time, start_time, MINUTE) AS ride_length_min,
  EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week
FROM
  `hip-limiter-442223-b8.cyclistic_case_study.cyclistic_trips_full_year_tbl`;
