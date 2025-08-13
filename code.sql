CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::554739427960:role/snowflake-vyaskov'
  STORAGE_ALLOWED_LOCATIONS = ('*');

  DESC INTEGRATION s3_integration;

  CREATE OR REPLACE FILE FORMAT csv_format
    TYPE = 'CSV'
    COMPRESSION = 'AUTO'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    TRIM_SPACE = TRUE,
    FIELD_OPTIONALLY_ENCLOSED_BY='"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ;

CREATE OR REPLACE FILE FORMAT parquet_format
    TYPE = 'PARQUET'
    COMPRESSION = 'AUTO'
    USE_LOGICAL_TYPE = TRUE;

  CREATE OR REPLACE STAGE s3_stage
  STORAGE_INTEGRATION = s3_integration
  URL = 's3://vyaskov-hw3/'
  FILE_FORMAT = csv_format;

  CREATE OR REPLACE STAGE s3_stage_rd_parquet
  STORAGE_INTEGRATION = s3_integration
  URL = 's3://robot-dreams-source-data/'
  FILE_FORMAT = parquet_format;

  LIST @s3_stage;

  SELECT t.$1, t.$2, t.$3, t.$4 FROM @s3_stage_rd_csv/home-work-1/nyc_taxi/taxi_zone_lookup.csv as t;

CREATE OR REPLACE WAREHOUSE HW3_WH
WITH WAREHOUSE_SIZE='X-LARGE'
AUTO_SUSPEND = 10
AUTO_RESUME = TRUE;

USE WAREHOUSE HW3_WH;

  COPY INTO TAXI_ZONE_LOOKUP
  FROM @s3_stage_rd_csv/home-work-1/nyc_taxi/taxi_zone_lookup.csv;

  select *
  from TAXI_ZONE_LOOKUP;

-------------------------
--drop table VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW
--truncate table VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW

create or replace TABLE VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW (
	VENDORID NUMBER(38,0),
	PASSENGER_COUNT NUMBER(38,0),
	TRIP_DISTANCE FLOAT,
	RATECODEID NUMBER(38,0),
	STORE_AND_FWD_FLAG VARCHAR,
	PULOCATIONID NUMBER(38,0),
	DOLOCATIONID NUMBER(38,0),
	PAYMENT_TYPE NUMBER(38,0), 
	FARE_AMOUNT FLOAT,
	EXTRA FLOAT,
	MTA_TAX FLOAT,
	TIP_AMOUNT FLOAT,
	TOLLS_AMOUNT FLOAT,
	IMPROVEMENT_SURCHARGE FLOAT,
	TOTAL_AMOUNT FLOAT,
	CONGESTION_SURCHARGE FLOAT,
	LPEP_PICKUP_DATETIME TIMESTAMP,
	LPEP_DROPOFF_DATETIME TIMESTAMP
);

/*
COPY INTO VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW
FROM @s3_stage_rd_parquet/home-work-1/nyc_taxi/green/2015/green_tripdata_2015-01.parquet
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
  */
  
select count(*) from VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW 
where lpep_dropoff_datetime is null 

--select * from VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW limit 10

COPY INTO VYASKOV_HW3.PUBLIC.GREEN_TAXI_RAW
FROM @s3_stage_rd_parquet/home-work-1/nyc_taxi/green/2023/
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
--ON_ERROR = CONTINUE;

2014+
2015+
2016+
2017+
2018+
2019+
2020+
2021+
2022+
2023+

--SELECT * FROM @s3_stage_rd_parquet/home-work-1-unified/nyc_taxi/green/2017/part-00001-tid-5741062207088412734-79c7f209-7599-4663-931e-4381538fa671-1254-1-c000.snappy.parquet  as t;

--drop table VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW
--truncate table VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW

create or replace TABLE VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW (
	VENDORID NUMBER(38,0),
	PASSENGER_COUNT NUMBER(38,0),
	TRIP_DISTANCE FLOAT,
	RATECODEID NUMBER(38,0),
	STORE_AND_FWD_FLAG VARCHAR,
	PULOCATIONID NUMBER(38,0),
	DOLOCATIONID NUMBER(38,0),
	PAYMENT_TYPE NUMBER(38,0),
	FARE_AMOUNT FLOAT,
	EXTRA FLOAT,
	MTA_TAX FLOAT,
	TIP_AMOUNT FLOAT,
	TOLLS_AMOUNT FLOAT,
	IMPROVEMENT_SURCHARGE FLOAT,
	TOTAL_AMOUNT FLOAT,
	CONGESTION_SURCHARGE FLOAT,
	TPEP_PICKUP_DATETIME TIMESTAMP,
	TPEP_DROPOFF_DATETIME TIMESTAMP,
	AIRPORT_FEE FLOAT
);

/*
select count(*) from VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW
select * from VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW limit 10

select count(*) from VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW --
where TPEP_PICKUP_DATETIME is null --
*/
COPY INTO VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW
FROM @s3_stage_rd_parquet/home-work-1/nyc_taxi/yellow/2023/
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
--ON_ERROR = CONTINUE;

2014+
2015+ --311486810
2016+ --442618615
2017+ --556118942
2018+ --658990329
2020+ --677340054
2022+ --716996152
2023+ --745067811

----------------------------------
create table VYASKOV_HW3.PUBLIC.yellow_enriched 
as 
select y.*, 
l1.zone as PICKUP_ZONE,
l2.zone as DROPOFF_ZONE,
hour(y.tpep_pickup_datetime) as PICKUP_HOUR,
case 
    when trip_distance <= 2 then 'Short'
    when trip_distance > 2 and trip_distance < 10 then 'Medium'
    when trip_distance >= 10 then 'Long'
end as TRIP_CATEGORY
from VYASKOV_HW3.PUBLIC.YELLOW_TAXI_RAW y
left join VYASKOV_HW3.PUBLIC.TAXI_ZONE_LOOKUP l1 ON y.pulocationid = l1.locationid
left join VYASKOV_HW3.PUBLIC.TAXI_ZONE_LOOKUP l2 ON y.dolocationid = l2.locationid
where y.trip_distance > 0
and y.total_amount > 0 
and y.passenger_count between 1 and 6;


create table VYASKOV_HW3.PUBLIC.yellow_ZONE_SUMMARY
as 
select 
y.PICKUP_ZONE,
count(*) as TOTAL_TRIPS,
avg(y.trip_distance) as AVG_TRIP_DISTANCE,
avg(y.TOTAL_AMOUNT) as AVG_TOTAL_AMOUNT,
avg(y.TIP_AMOUNT) as AVG_TIP_AMOUNT,
max(y.trip_distance) as MAX_TRIP_DISTANCE,
min(y.TIP_AMOUNT) as MIN_TIP_AMOUNT
from VYASKOV_HW3.PUBLIC.yellow_enriched y
group by 1
---------------------------------------------------------------

create table VYASKOV_HW3.PUBLIC.green_enriched 
as 
select g.*, 
l1.zone as PICKUP_ZONE,
l2.zone as DROPOFF_ZONE,
hour(g.LPEP_PICKUP_DATETIME) as PICKUP_HOUR,
case 
    when trip_distance <= 2 then 'Short'
    when trip_distance > 2 and trip_distance < 10 then 'Medium'
    when trip_distance >= 10 then 'Long'
end as TRIP_CATEGORY
from VYASKOV_HW3.PUBLIC.green_TAXI_RAW g
left join VYASKOV_HW3.PUBLIC.TAXI_ZONE_LOOKUP l1 ON g.pulocationid = l1.locationid
left join VYASKOV_HW3.PUBLIC.TAXI_ZONE_LOOKUP l2 ON g.dolocationid = l2.locationid
where g.trip_distance > 0
and g.total_amount > 0 
and g.passenger_count between 1 and 6;


create table VYASKOV_HW3.PUBLIC.green_ZONE_SUMMARY
as 
select 
g.PICKUP_ZONE,
count(*) as TOTAL_TRIPS,
avg(g.trip_distance) as AVG_TRIP_DISTANCE,
avg(g.TOTAL_AMOUNT) as AVG_TOTAL_AMOUNT,
avg(g.TIP_AMOUNT) as AVG_TIP_AMOUNT,
max(g.trip_distance) as MAX_TRIP_DISTANCE,
min(g.TIP_AMOUNT) as MIN_TIP_AMOUNT
from VYASKOV_HW3.PUBLIC.green_enriched g
group by 1

-------------------------------------------------------------------
CREATE TABLE VYASKOV_HW3.PUBLIC.green_enriched_test
as
select *
from VYASKOV_HW3.PUBLIC.green_enriched limit 10000;

--drop table VYASKOV_HW3.PUBLIC.clone_green_enriched
--CREATE TABLE VYASKOV_HW3.PUBLIC.clone_green_enriched  CLONE VYASKOV_HW3.PUBLIC.green_enriched ;

select *
from VYASKOV_HW3.PUBLIC.green_enriched_test
where pickup_zone = 'East Harlem South'
limit 10;

delete from VYASKOV_HW3.PUBLIC.green_enriched_test
where pickup_zone = 'East Harlem South';


/*
SELECT * FROM VYASKOV_HW3.PUBLIC.green_enriched_test BEFORE(STATEMENT => LAST_QUERY_ID())
where pickup_zone = 'East Harlem South';
*/

insert into VYASKOV_HW3.PUBLIC.green_enriched_test
SELECT * FROM VYASKOV_HW3.PUBLIC.green_enriched_test BEFORE(TIMESTAMP => '2025-08-13 09:38:00'::TIMESTAMP)
where pickup_zone = 'East Harlem South'
;

-------------------------------------------
CREATE STREAM VYASKOV_HW3.PUBLIC.yellow_stream ON TABLE VYASKOV_HW3.PUBLIC.yellow_enriched ;
/*
SELECT *
FROM VYASKOV_HW3.PUBLIC.yellow_stream;

SELECT *
FROM VYASKOV_HW3.PUBLIC.yellow_enriched where  pickup_zone = 'East Harlem South';

DELETE FROM VYASKOV_HW3.PUBLIC.yellow_enriched WHERE pickup_zone = 'East Harlem South';

delete from VYASKOV_HW3.PUBLIC.yellow_enriched
WHERE  pickup_zone = 'East Harlem South';
*/

insert into VYASKOV_HW3.PUBLIC.yellow_enriched(VENDORID, PASSENGER_COUNT, TRIP_DISTANCE, PULOCATIONID, DOLOCATIONID, PAYMENT_TYPE, FARE_AMOUNT, TPEP_PICKUP_DATETIME, TPEP_DROPOFF_DATETIME)
values(3, 112, 112, 79, 230, 1, 10,'2020-05-01 00:54:58.000','2020-05-01 00:57:11.000')

create table VYASKOV_HW3.PUBLIC.yellow_changes_log 
as select * from VYASKOV_HW3.PUBLIC.yellow_stream;

--truncate table VYASKOV_HW3.PUBLIC.yellow_changes_log
select * from VYASKOV_HW3.PUBLIC.yellow_changes_log 

CREATE OR REPLACE TASK VYASKOV_HW3.PUBLIC.stream_task
--WAREHOUSE = HW3_WH
  TARGET_COMPLETION_INTERVAL='1 HOUR'
  WHEN SYSTEM$STREAM_HAS_DATA('yellow_stream')
  AS
  INSERT INTO VYASKOV_HW3.PUBLIC.yellow_changes_log 
    SELECT * --EXCLUDE(METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID)
     FROM VYASKOV_HW3.PUBLIC.yellow_stream;



CREATE OR REPLACE TASK VYASKOV_HW3.PUBLIC.stream_task
--WAREHOUSE = HW3_WH
TARGET_COMPLETION_INTERVAL='1 HOUR'
WHEN SYSTEM$STREAM_HAS_DATA('VYASKOV_HW3.PUBLIC.yellow_stream')
AS
INSERT INTO VYASKOV_HW3.PUBLIC.yellow_changes_log
SELECT *
FROM VYASKOV_HW3.PUBLIC.yellow_stream
--EXCLUDE(METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID);

--EXECUTE TASK VYASKOV_HW3.PUBLIC.task7_hourly_stats;

create or replace task VYASKOV_HW3.PUBLIC.task7_hourly_stats
WAREHOUSE = HW3_WH
  SCHEDULE = '1 HOUR'
as 
INSERT INTO VYASKOV_HW3.PUBLIC.zone_hourly_stats
SELECT
  AVG(trip_distance) AS avg_distance,
  AVG(total_amount) AS avg_total_amount,
  COUNT(*) AS trips_qt
FROM VYASKOV_HW3.PUBLIC.yellow_enriched
WHERE
  trip_distance > 0 AND total_amount > 0 AND passenger_count BETWEEN 1 AND 6;



select * from VYASKOV_HW3.PUBLIC.zone_hourly_stats
