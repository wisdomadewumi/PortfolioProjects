/*
===========================================================================
Bulk Data Loading into Transport Data
===========================================================================
Script Purpose:
	

Functions:
	1. Truncates Existing Data: Ensures that the tables are emptied before new data is inserted to prevent duplication.
	2. Bulk Inserts Data from CSV Files: Loads data efficiently into tables using BULK INSERT.
*/


PRINT '=====================================';
PRINT 'Loading First 5 Tables';
PRINT '=====================================';

-- Table 1: tripsdb.dim_city
PRINT '>> Truncating Table: tripsdb.dim_city';
TRUNCATE TABLE tripsdb.dim_city;
	
PRINT '>> Inserting Data Into: tripsdb.dim_city';
BULK INSERT tripsdb.dim_city
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\dim_city.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 2: tripsdb.dim_date
PRINT '>> Truncating Table: tripsdb.dim_date';
TRUNCATE TABLE tripsdb.dim_date;
	
PRINT '>> Inserting Data Into: tripsdb.dim_date';
BULK INSERT tripsdb.dim_date
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\dim_date.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 3: tripsdb.fact_passenger_summary
PRINT '>> Truncating Table: tripsdb.fact_passenger_summary';
TRUNCATE TABLE tripsdb.fact_passenger_summary;
	
PRINT '>> Inserting Data Into: tripsdb.fact_passenger_summary';
BULK INSERT tripsdb.fact_passenger_summary
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\fact_passenger_summary.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 4: tripsdb.dim_repeat_trip_distribution
PRINT '>> Truncating Table: tripsdb.dim_repeat_trip_distribution';
TRUNCATE TABLE tripsdb.dim_repeat_trip_distribution;
	
PRINT '>> Inserting Data Into: tripsdb.dim_repeat_trip_distribution';
BULK INSERT tripsdb.dim_repeat_trip_distribution
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\dim_repeat_trip_distribution.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 5: tripsdb.fact_trips
PRINT '>> Truncating Table: tripsdb.fact_trips';
TRUNCATE TABLE tripsdb.fact_trips;
	
PRINT '>> Inserting Data Into: tripsdb.fact_trips';
BULK INSERT tripsdb.fact_trips
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\fact_trips.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


PRINT '=====================================';
PRINT 'Loading Last 3 Tables';
PRINT '=====================================';


-- Table 6: targetsdb.city_target_passenger_rating
PRINT '>> Truncating Table: targetsdb.city_target_passenger_rating';
TRUNCATE TABLE targetsdb.city_target_passenger_rating;
	
PRINT '>> Inserting Data Into: targetsdb.city_target_passenger_rating';
BULK INSERT targetsdb.city_target_passenger_rating
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\city_target_passenger_rating.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 7: targetsdb.monthly_target_new_passengers
PRINT '>> Truncating Table: targetsdb.monthly_target_new_passengers';
TRUNCATE TABLE targetsdb.monthly_target_new_passengers;
	
PRINT '>> Inserting Data Into: targetsdb.monthly_target_new_passengers';
BULK INSERT targetsdb.monthly_target_new_passengers
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\monthly_target_new_passengers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 8: targetsdb.monthly_target_trips
PRINT '>> Truncating Table: targetsdb.monthly_target_trips';
TRUNCATE TABLE targetsdb.monthly_target_trips;
	
PRINT '>> Inserting Data Into: targetsdb.monthly_target_trips';
BULK INSERT targetsdb.monthly_target_trips
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\07_Transport_Data-Analytics-Project\dataset\csv_files\monthly_target_trips.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);