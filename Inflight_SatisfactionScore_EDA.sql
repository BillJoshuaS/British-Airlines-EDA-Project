CREATE DATABASE Airline;

USE Airline;
SELECT * FROM passanger_booking_data;

CREATE TABLE customer_comment (
  S_num INT,
  flight_number VARCHAR(20),
  origin_station_code VARCHAR(10),
  destination_station_code VARCHAR(10),
  scheduled_departure_date DATE,
  arrival_delay_group VARCHAR(50),
  departure_delay_group VARCHAR(50),
  entity VARCHAR(100),
  verbatim_text TEXT,
  seat_factor_band VARCHAR(50),
  ques_verbatim_text TEXT,
  loyalty_program_level VARCHAR(50),
  fleet_type_description VARCHAR(50),
  fleet_usage VARCHAR(50),
  response_group VARCHAR(50),
  sentiments VARCHAR(20),
  transformed_text TEXT
);

-- To check the location of sucurity privileage file:
SHOW VARIABLES LIKE 'secure_file_priv';

-- To import data from secured local location: 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer_comment.csv'
INTO TABLE customer_comment
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Staging (Creating only the table header):
CREATE TABLE passanger_booking_data_staged
LIKE passanger_booking_data;

CREATE TABLE inflight_satisfaction_score_staged
LIKE inflight_satisfaction_score;

CREATE TABLE customer_comment_staged
LIKE customer_comment;

SELECT * FROM passanger_booking_data_staged;

-- Inserting the values from corresponding raw data tables:

INSERT passanger_booking_data_staged
SELECT *
FROM passanger_booking_data;

INSERT inflight_satisfaction_score_staged
SELECT *
FROM inflight_satisfaction_score;

INSERT customer_comment_staged
SELECT *
FROM customer_comment;

SELECT COUNT(*) FROM inflight_satisfaction_score;
-- To rename the nameless column in Customer_comment:
ALTER TABLE customer_comment RENAME COLUMN MyUnknownColumn TO s_num;

-- Make the s_num column start from 1:
SET SQL_SAFE_UPDATES = 0;
UPDATE customer_comment SET s_num = s_num + 1;
SET SQL_SAFE_UPDATES = 1;

-- To find the duplicates from a table:
select count(flight_number) as total_count, count(distinct flight_number)
from customer_comment;

select flight_number, count(flight_number) count_num from customer_comment group by flight_number;

-- Checking if the comments are repeated at several places in customer_comment:
select verbatim_text, count(*) count_n from customer_comment group by verbatim_text having count(*)>1;

-- Checking for false duplicates and look alikes: 
SELECT destination_station_code, COUNT(destination_station_code) FROM customer_comment_stagedv1 GROUP BY destination_station_code having COUNT(destination_station_code)< 2;
SELECT destination_station_code FROM customer_comment_stagedv1 WHERE destination_station_code LIKE '%ECX%';

DESC inflight_satisfaction_score_staged; -- Here I found a column name is scambled due to encoding mismatch
ALTER TABLE inflight_satisfaction_score_staged CHANGE COLUMN `ï»¿flight_number` flight_number int;

-- To see if all the prime factors are duplicated: 
SELECT flight_number,origin_station_code,destination_station_code,scheduled_departure_date,score,arrival_delay_minutes, COUNT(*) 
from inflight_satisfaction_score_staged GROUP BY flight_number,origin_station_code,destination_station_code,scheduled_departure_date,score,arrival_delay_minutes
HAVING COUNT(*) > 4;

-- To get all the column names of a table in a single row:
SET SESSION group_concat_max_len = 1000000; -- TO increase max length displyable in a row. 
SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ')
AS column_list
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'inflight_satisfaction_score_staged'
  AND TABLE_SCHEMA = 'Airline';

-- To get all the column names row wise: 
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'inflight_satisfaction_score_staged'
  AND TABLE_SCHEMA = 'Airline'
ORDER BY ORDINAL_POSITION;

WITH DUP_CHECK AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY flight_number, origin_station_code, destination_station_code, record_locator, scheduled_departure_date, question_text, score, satisfaction_type, driver_sub_group1, driver_sub_group2, arrival_delay_minutes, arrival_delay_group, cabin_code_desc, cabin_name, entity, number_of_legs, seat_factor_band, loyalty_program_level, generation, fleet_type_description, fleet_usage, equipment_type_code, ua_uax, actual_flown_miles, haul_type, departure_gate, arrival_gate, international_domestic_indicator, response_group, media_provider, hub_spoke
) AS row_num
FROM inflight_satisfaction_score_staged
)
SELECT * FROM DUP_CHECK WHERE row_num > 1;

-- Checking if same comment added at same date and same flight with CTE and window func:
WITH COMMENT_CHECK AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY scheduled_departure_date, flight_number, verbatim_text) AS ROW_NUM
FROM CUSTOMER_COMMENT
)
SELECT * FROM COMMENT_CHECK WHERE ROW_NUM > 1;


-- Creating a stage table to hold the above filtered records:
DESC customer_comment;
CREATE TABLE `customer_comment_stagedv1`
(
`s_num` int,
`flight_number` varchar(20),
`origin_station_code` varchar(10),
`destination_station_code` varchar(10),
`scheduled_departure_date` date,
`arrival_delay_group` varchar(50),
`departure_delay_group` varchar(50),
`entity` varchar(100),
`verbatim_text` text,
`seat_factor_band` varchar(50),
`ques_verbatim_text` text,
`loyalty_program_level` varchar(50),
`fleet_type_description` varchar(50),
`fleet_usage` varchar(50),
`response_group` varchar(50),
`sentiments` varchar(20),
`transformed_text` text,
`row_num` int
);

INSERT INTO customer_comment_stagedv1
SELECT *, ROW_NUMBER() OVER(PARTITION BY scheduled_departure_date, flight_number, verbatim_text) AS ROW_NUM
FROM CUSTOMER_COMMENT;

-- Deleting the duplicate files:
SET SQL_SAFE_UPDATES = 0;
DELETE FROM customer_comment_stagedv1 WHERE row_num > 1;
SET SQL_SAFE_UPDATES = 1;

-- After deleting the duplicates, we can simply remove the row_num column as it wont serve a purpose anymore.
ALTER TABLE customer_comment_stagedv1
DROP COLUMN row_num;

SELECT * FROM customer_comment_stagedv1 WHERE row_num > 1;
SELECT * FROM customer_comment_stagedv1;

-- Checking if same comment added at same date and same flight with group by:
select scheduled_departure_date, flight_number, verbatim_text, count(*) count_n from customer_comment group by scheduled_departure_date, flight_number, verbatim_text having count(*)>1;

select * from customer_comment;
SELECT * FROM INFLIGHT_SATISFACTION_SCORE;

select count(*) from customer_comment;
select count(*) from inflight_satisfaction_score;


-- Standardization of data (Checking issues in data and cleaning the noises) 
SELECT * FROM passanger_booking_data_staged;

select count(*) from passanger_booking_data_staged; -- To see table true length.

SELECT DISTINCT TRIM(booking_origin) FROM passanger_booking_data_staged;
SELECT booking_origin, TRIM(booking_origin) from passanger_booking_data_staged;
SELECT COUNT(booking_origin) FROM passanger_booking_data_staged WHERE booking_origin = "RÃ©union";

SELECT DISTINCT destination_station_code FROM customer_comment_stagedv1 ORDER BY 1;

-- Trimming character string data in customer_comment_staged table:
SELECT verbatim_text, TRIM(verbatim_text) FROM customer_comment_stagedv1;
UPDATE customer_comment_stagedv1 SET verbatim_text = TRIM(verbatim_text);

SELECT verbatim_text, TRIM(transformed_text) FROM customer_comment_stagedv1;
UPDATE customer_comment_stagedv1 SET transformed_text = TRIM(transformed_text);



-- TRIMMING THE DATA BEFORE MODIFYING:
UPDATE passanger_booking_data_staged SET booking_origin = TRIM(booking_origin);

-- Replacing the wrong encoded value:
UPDATE passanger_booking_data_staged SET booking_origin = "Reunion"
WHERE booking_origin LIKE "RÃ©union";

-- checking the date format for time series analysis:
SELECT `scheduled_departure_date`,
STR_TO_DATE(`scheduled_departure_date`, '%m%d%Y')
FROM customer_comment_stagedv1;

SELECT `scheduled_departure_date`
FROM inflight_satisfaction_score_staged;

SELECT COUNT(*) FROM inflight_satisfaction_score_staged;
SELECT * FROM inflight_satisfaction_score_staged;

UPDATE inflight_satisfaction_score_staged
SET `scheduled_departure_date` = STR_TO_DATE(`scheduled_departure_date`, '%c-%e-%Y')
WHERE `scheduled_departure_date` LIKE '__-__-____';

-- Once date formatted we are changing the type to DATE from TEXT:
ALTER TABLE inflight_satisfaction_score_staged
MODIFY COLUMN scheduled_departure_date DATE;

-- UPDATE inflight_satisfaction_score_staged
-- SET scheduled_departure_date = STR_TO_DATE(scheduled_departure_date, '%c/%e/%Y')
-- WHERE scheduled_departure_date LIKE '%/%/%';

-- Handling NULL values:

-- To print NULL Vlaues 
SELECT * FROM inflight_satisfaction_score_staged WHERE flight_number IS NULL;
SELECT COUNT(*) FROM customer_comment_stagedv1;
SELECT * FROM customer_comment_stagedv1 LIMIT 30;

-- To get the count of NULL
SELECT COUNT(*) as null_cnt FROM inflight_satisfaction_score_staged WHERE cabin_name IS NULL OR cabin_name = '' OR cabin_name = ' ';
SELECT COUNT(*) as null_cnt FROM customer_comment_stagedv1 WHERE transformed_text IS NULL OR transformed_text = '' OR transformed_text = ' ';

-- Found that the s_num is scrambled now, we drop and add it in numerical order:
ALTER TABLE customer_comment_stagedv1 DROP COLUMN s_num;
ALTER TABLE customer_comment_stagedv1 ADD COLUMN s_num INT;

SET @row_number = 0;
UPDATE customer_comment_stagedv1
SET s_num = (@row_number := @row_number+1);

-- To bring the new s_num col to first position: 
ALTER TABLE customer_comment_stagedv1 MODIFY COLUMN s_num INT FIRST;

-- Removing the NULL records from entity column from Survey data inflight Satisfaction table:
SELECT COUNT(*) FROM inflight_satisfaction_score_staged; 
SELECT * FROM inflight_satisfaction_score_staged;

-- Entity = 3 NULL or empty records (Decided to remove the records) 
SELECT entity FROM inflight_satisfaction_score_staged WHERE entity IS NULL OR TRIM(entity) = '';
DELETE FROM inflight_satisfaction_score_staged WHERE entity IS NULL OR TRIM(entity) = '';

SELECT * FROM inflight_satisfaction_score_staged WHERE cabin_code_desc = 'Business';
SELECT COUNT(*) FROM inflight_satisfaction_score_staged WHERE cabin_name = "" OR cabin_name IS NULL;

--  Removing cabin_name since 11k NULL and making cabin_code_desc as the major cabin type decider:
SELECT * FROM inflight_satisfaction_score_staged
WHERE TRIM(cabin_name) = 'Economy Plus';

UPDATE inflight_satisfaction_score_staged
SET cabin_code_desc = cabin_name WHERE TRIM(cabin_name) = 'Economy Plus';

-- Now removing the cabin_name field as we dont need that anymore since we are using cabin_code_desc
SELECT version();
ALTER TABLE inflight_satisfaction_score_staged DROP COLUMN cabin_name;
DESC TABLE inflight_satisfaction_score_staged;
SHOW COLUMNS FROM inflight_satisfaction_score_staged;

-- Loyalty_program_level here we have NULL values and these values are assumed as non-members to the Airlines:
SELECT COUNT(*) FROM inflight_satisfaction_score_staged WHERE loyalty_program_level IS NULL OR loyalty_program_level = '';

UPDATE inflight_satisfaction_score_staged SET loyalty_program_level = 'guest' WHERE loyalty_program_level IS NULL OR loyalty_program_level = '';

SELECT * FROM inflight_satisfaction_score_staged;

-- Handle missing Vlaues in Departure and Arrival gate fields and set a placeholder as Not Provided NP:
UPDATE inflight_satisfaction_score_staged
SET departure_gate = 'NP' WHERE departure_gate = '' OR departure_gate IS NULL;

UPDATE inflight_satisfaction_score_staged
SET arrival_gate = 'NP' WHERE arrival_gate = '' OR arrival_gate IS NULL;

SELECT * FROM passenger_booking_cleaned;
SELECT COUNT(*) FROM passenger_booking_cleaned;
 
-- to find the number of unique rows
 SELECT COUNT(*) AS tot_rows,
 COUNT(DISTINCT flight_number,origin_station_code,destination_station_code,record_locator,scheduled_departure_date,question_text,score,satisfaction_type,driver_sub_group1,driver_sub_group2,arrival_delay_minutes,arrival_delay_group,cabin_code_desc,entity,number_of_legs,seat_factor_band,loyalty_program_level,generation,fleet_type_description,fleet_usage,equipment_type_code,ua_uax,actual_flown_miles,haul_type,departure_gate,arrival_gate,international_domestic_indicator,response_group,media_provider,hub_spoke)
 AS unique_rows
 FROM inflight_satisfaction_score_staged;
 
 -- To see the number of unique flights: 
 SELECT
 DISTINCT flight_number,origin_station_code,destination_station_code,scheduled_departure_date,arrival_delay_minutes,arrival_delay_group,fleet_type_description,equipment_type_code,actual_flown_miles,international_domestic_indicator
 ,COUNT(*) AS passenger_count
 FROM inflight_satisfaction_score_staged
 GROUP BY flight_number,origin_station_code,destination_station_code,scheduled_departure_date,arrival_delay_minutes,arrival_delay_group,fleet_type_description,equipment_type_code,actual_flown_miles	,international_domestic_indicator;
 
 -- Creating View of the unique_flights (view - Virtual Table)
 
CREATE OR REPLACE VIEW unique_flights AS
SELECT
flight_number,
origin_station_code,
destination_station_code,
scheduled_departure_date,
arrival_delay_minutes,
arrival_delay_group,
fleet_type_description,
equipment_type_code,
actual_flown_miles,
international_domestic_indicator,
COUNT(flight_number) AS passenger_count
FROM inflight_satisfaction_score_staged
GROUP BY 
flight_number,
origin_station_code,
destination_station_code,
scheduled_departure_date,
arrival_delay_minutes,
arrival_delay_group,
fleet_type_description,
equipment_type_code,
actual_flown_miles,
international_domestic_indicator;

SELECT COUNT(DISTINCT FLIGHT_NUMBER) FROM unique_flights;
SELECT * FROM unique_flights WHERE flight_number = 3609;

CREATE OR REPLACE VIEW departure_delays AS
SELECT
flight_number,
departure_delay_group,
scheduled_departure_date,
COUNT(*) AS passenger_count
FROM customer_comment_stagedv1
GROUP BY
flight_number,
departure_delay_group,
scheduled_departure_date;

SELECT * FROM DEPARTURE_DELAYS LIMIT 20;
SELECT * FROM inflight_satisfaction_score_staged LIMIT 10;

-- Counting the number of countries British Airlines provide service 
SELECT COUNT(DISTINCT booking_origin) FROM passenger_booking_cleaned;

-- To view the countries with most and least bookings among the 93 total countries:
SELECT booking_origin, COUNT(*) AS successful_booking FROM passenger_booking_cleaned WHERE booking_complete = 1 GROUP BY booking_origin;

WITH country_booking AS (
	SELECT booking_origin, COUNT(*) AS successful_booking 
    FROM passenger_booking_cleaned 
    WHERE booking_complete = 1 
    GROUP BY booking_origin
)
SELECT * 
FROM country_booking
WHERE successful_booking = (SELECT MAX(successful_booking) FROM country_booking)
OR successful_booking = (SELECT MIN(successful_booking) FROM country_booking);


-- Need to add neutral category in the satisfaction_type feature since a score of 3 could be segregated and analysed as neutral.
UPDATE inflight_satisfaction_score_staged SET satisfaction_type = "Neutral" WHERE score = 3;