/*
===========================================================================
Data Structure Definition for Transport Data
===========================================================================
This file contains all the meta information regarding the columns described in the CSV files. 8 CSV files have been provided.
1. dim_city
2. dim_date
3. fact_passenger_summary
4. dim_repeat_trip_distribution
5. fact_trips
6. city_target_passenger_rating
7. monthly_target_new_passengers
8. monthly_target_trips
	
*/

USE PortfolioProject;
GO

-- Create Two Schemas
CREATE SCHEMA tripsdb;
GO

CREATE SCHEMA targetsdb;
GO

/*
===========================
	1. tripsdb - 1st set of tables
	-- This database contains both detailed and aggregated data on trips, passenger types, and repeat trip behavior for Goodcabs' operations across tier-2 cities. It organizes trip data by city, month, and day type (weekday or weekend), enabling comprehensive analysis of travel patterns, passenger demographics, and repeat usage trends.
===========================
*/


/*
1. tripsdb.dim_city
Purpose: This table provides city-specific details, enabling location-based analysis of trips and passenger behavior across Goodcabs’ operational areas.

	- city_id: A unique identifier for each city, using a standardized code (e.g., RJ01 for Jaipur).
	- city_name: The name of the city where Goodcabs operates (e.g., Jaipur, Lucknow), used for location-based grouping and insights.

*/

IF OBJECT_ID ('tripsdb.dim_city', 'U') IS NOT NULL
	DROP TABLE tripsdb.dim_city;
CREATE TABLE tripsdb.dim_city (
	city_id			NVARCHAR(10),
	city_name		NVARCHAR(20)
);
GO


/*
2. tripsdb.dim_date
Purpose: This table provides date-specific details that enable time-based grouping and analysis, helping to identify patterns across days, months, and weekends versus weekdays.

	- date: The specific date for each entry (formatted as YYYY-MM-DD), used for daily-level analysis and to join with trip data.
	- start_of_month: The first day of the month to which the date belongs, useful for grouping data by month in analyses.
	- month_name: The name of the month (e.g., January, February) corresponding to the date, helpful for month-based aggregations.
	- day_type: Indicator of whether the date is a weekday or weekend, enabling analysis of demand and trip patterns across different day types.

*/

IF OBJECT_ID ('tripsdb.dim_date', 'U') IS NOT NULL
	DROP TABLE tripsdb.dim_date;
CREATE TABLE tripsdb.dim_date (
	date				DATE,
	start_of_month		DATE,
	month_name			NVARCHAR(20),
	day_type			NVARCHAR(20)
);
GO


/*
3. tripsdb.fact_passenger_summary
Purpose: This table provides an aggregated summary of passenger counts for each city by month. It includes data on total passengers, new passengers, and repeat passengers, giving a high-level overview of passenger distribution patterns across different locations and times.

	- month: The start date of the month (formatted as YYYY-MM-DD). All metrics in this table are aggregated for the entire month, aligning with other time-based analyses.
	- city_id: Unique identifier for the city.
	- total_passengers: The aggregated count of all passengers (both new and repeat) for the specified city and month.
	- new_passengers: The count of passengers taking their first ride in the specified city and month.
	- repeat_passengers: The count of passengers who have taken at least one ride in previous months and returned to ride again in the specified city and month.

*/

IF OBJECT_ID ('tripsdb.fact_passenger_summary', 'U') IS NOT NULL
	DROP TABLE tripsdb.fact_passenger_summary;
CREATE TABLE tripsdb.fact_passenger_summary (
	month				DATE,
	city_id				NVARCHAR(10),
	total_passengers	INT,
	new_passengers		INT,
	repeat_passengers	INT
);
GO


/*
4. tripsdb.dim_repeat_trip_distribution
Purpose: This table provides a breakdown of repeat trip behavior, aggregated by month and city. It details how many times repeat passengers rode within the given month, categorized by trip frequency. To keep things simple and ensure uniformity across cities, we have included trip frequencies up to a maximum of 10 trips per month. This allows for an analysis of repeat trip patterns at a granular level.

	- month: The start date of the month (formatted as YYYY-MM-DD). All metrics in this table represent aggregated values for the entire month, allowing alignment with other date-based analyses.
	- city_id: Unique identifier for the city.
	- trip_count: The number of trips taken by repeat passengers within the specified city and month (e.g., "3-Trips" for passengers who took 3 trips).
	- repeat_passenger_count: The count of repeat passengers associated with each specified trip_count for the city and month.

*/

IF OBJECT_ID ('tripsdb.dim_repeat_trip_distribution', 'U') IS NOT NULL
	DROP TABLE tripsdb.dim_repeat_trip_distribution;
CREATE TABLE tripsdb.dim_repeat_trip_distribution (
	month					DATE,
	city_id					NVARCHAR(10),
	trip_count				NVARCHAR(20),
	repeat_passenger_count	INT
);
GO


/*
5. tripsdb.fact_trips
Purpose: This table provides detailed information on each individual trip, including trip-specific metrics like distance, fare, and ratings, which can be used for granular trip-level analysis.

	- trip_id: Unique identifier for each trip.
	- date: The exact date of the trip (formatted as YYYY-MM-DD).
	- city_id: Unique identifier for the city where the trip took place.
	- passenger_type: Indicates if the passenger is new (first-time rider) or repeat (returning rider).
	- distance_travelled (km): Total distance covered in the trip, measured in kilometers.
	- fare_amount: Total fare amount paid by the passenger for the trip, in local currency.
	- passenger_rating: Rating provided by the passenger for the trip, on a scale from 1 to 10.
	- driver_rating: Rating provided by the driver for the passenger, on a scale from 1 to 10.
*/

IF OBJECT_ID ('tripsdb.fact_trips', 'U') IS NOT NULL
	DROP TABLE tripsdb.fact_trips;
CREATE TABLE tripsdb.fact_trips (
	trip_id					NVARCHAR(50),
	date					DATE,
	city_id					NVARCHAR(10),
	passenger_type			NVARCHAR(20),
	distance_travelled		INT,
	fare_amount				INT,
	passenger_rating		INT,
	driver_rating			INT
);
GO


/*
===========================
	2. targetsdb - 2nd set of tables
	-- This database holds Goodcabs' monthly targets for each city, including goals for trip counts, new passenger acquisition, and average passenger ratings. It enables performance evaluations against key benchmarks set by the company.
===========================
*/

/*
1. targetsdb.city_target_passenger_rating
	- city_id: Unique identifier for each city.
	- target_avg_passenger_rating: The target average passenger rating that Goodcabs aims to achieve for each city, used to monitor customer satisfaction.
*/

IF OBJECT_ID ('targetsdb.city_target_passenger_rating', 'U') IS NOT NULL
	DROP TABLE targetsdb.city_target_passenger_rating;
CREATE TABLE targetsdb.city_target_passenger_rating (
	city_id							NVARCHAR(10),
	target_avg_passenger_rating		FLOAT
);
GO


/*
2. targetsdb.monthly_target_new_passengers
	- month: The start date of the target month (formatted as YYYY-MM-DD) to align with other time-based data.
	- city_id: Unique identifier for each city.
	- target_new_passengers: The target number of new passengers Goodcabs aims to acquire in each city for the specified month, supporting growth tracking.

*/

IF OBJECT_ID ('targetsdb.monthly_target_new_passengers', 'U') IS NOT NULL
	DROP TABLE targetsdb.monthly_target_new_passengers;
CREATE TABLE targetsdb.monthly_target_new_passengers (
	month					DATE,
	city_id					NVARCHAR(10),
	target_new_passengers	INT
);
GO


/*
3. targetsdb.monthly_target_trips
	- month: The start date of the target month (formatted as YYYY-MM-DD) for easy alignment with monthly performance data.
	- city_id: Unique identifier for each city.
	- total_target_trips: The target number of total trips Goodcabs aims to achieve for each city and month, enabling assessment of trip volume performance.
*/

IF OBJECT_ID ('targetsdb.monthly_target_trips', 'U') IS NOT NULL
	DROP TABLE targetsdb.monthly_target_trips;
CREATE TABLE targetsdb.monthly_target_trips (
	month					DATE,
	city_id					NVARCHAR(10),
	total_target_trips		INT
);
GO