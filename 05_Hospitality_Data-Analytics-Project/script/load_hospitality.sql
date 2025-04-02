/*
===========================================================================
Bulk Data Loading into Hospitality Data Schema
===========================================================================
Script Purpose:
	

Functions:
	1. Truncates Existing Data: Ensures that the tables are emptied before new data is inserted to prevent duplication.
	2. Bulk Inserts Data from CSV Files: Loads data efficiently into tables using BULK INSERT.
*/


PRINT '=====================================';
PRINT 'Loading All 5 Tables';
PRINT '=====================================';

-- Table 1: hospitality.dim_date
PRINT '>> Truncating Table: hospitality.dim_date';
TRUNCATE TABLE hospitality.dim_date;
	
PRINT '>> Inserting Data Into: hospitality.dim_date';
BULK INSERT hospitality.dim_date
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\05_Hospitality_Data-Analytics-Project\dataset\dim_date.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 2: hospitality.dim_hotels
PRINT '>> Truncating Table: hospitality.dim_hotels';
TRUNCATE TABLE hospitality.dim_hotels;
	
PRINT '>> Inserting Data Into: hospitality.dim_hotels';
BULK INSERT hospitality.dim_hotels
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\05_Hospitality_Data-Analytics-Project\dataset\dim_hotels.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 3: hospitality.dim_rooms
PRINT '>> Truncating Table: hospitality.dim_rooms';
TRUNCATE TABLE hospitality.dim_rooms;
	
PRINT '>> Inserting Data Into: hospitality.dim_rooms';
BULK INSERT hospitality.dim_rooms
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\05_Hospitality_Data-Analytics-Project\dataset\dim_rooms.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 4: hospitality.fact_aggregated_bookings
PRINT '>> Truncating Table: hospitality.fact_aggregated_bookings';
TRUNCATE TABLE hospitality.fact_aggregated_bookings;
	
PRINT '>> Inserting Data Into: hospitality.fact_aggregated_bookings';
BULK INSERT hospitality.fact_aggregated_bookings
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\05_Hospitality_Data-Analytics-Project\dataset\fact_aggregated_bookings.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- Table 5: hospitality.fact_bookings
PRINT '>> Truncating Table: hospitality.fact_bookings';
TRUNCATE TABLE hospitality.fact_bookings;
	
PRINT '>> Inserting Data Into: hospitality.fact_bookings';
BULK INSERT hospitality.fact_bookings
FROM 'C:\Users\wisdo\Documents\Coursera\PortfolioProjects\05_Hospitality_Data-Analytics-Project\dataset\fact_bookings.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);