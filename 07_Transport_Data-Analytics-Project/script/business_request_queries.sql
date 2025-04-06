/*
==================================
Codebasics: Provide Insights to Chief of Operations in Transportation Domain
==================================

Domain:  Transportation & Mobility          Function: Operations 

Goodcabs, a cab service company established two years ago, has gained a strong foothold in the Indian market by focusing on tier-2 cities. Unlike other cab service providers, Goodcabs is committed to supporting local drivers, helping them make a sustainable living in their hometowns while ensuring excellent service to passengers. With operations in ten tier-2 cities across India, Goodcabs has set ambitious performance targets for 2024 to drive growth and improve passenger satisfaction. 

As part of this initiative, the Goodcabs management team aims to assess the company’s performance across key metrics, including trip volume, passenger satisfaction, repeat passenger rate, trip distribution, and the balance between new and repeat passengers. 

However, the Chief of Operations, Bruce Haryali, wanted this immediately but the analytics manager Tony is engaged on another critical project. Tony decided to give this work to Peter Pandey who is the curious data analyst of Goodcabs. Since these insights will be directly reported to the Chief of Operations, Tony also provided some notes to Peter to support his work.

*/

USE PortfolioProject;

-- Tasks to complete

/*
==================================
Request 1: City-Level Fare and Trip Summary Report
==================================
*/

SELECT
	c.city_name,
	COUNT(t.trip_id) AS total_trips,
	SUM(t.fare_amount) / SUM(t.distance_travelled) AS avg_fare_per_km,
	SUM(t.fare_amount) / COUNT(t.trip_id) AS avg_fare_per_trip,
	ROUND(100 * (COUNT(t.trip_id) / CAST(SUM(COUNT(t.trip_id)) OVER() AS FLOAT)), 2) AS [%_contribution_to_total_trips]
FROM tripsdb.fact_trips AS t
LEFT JOIN tripsdb.dim_city AS c
ON c.city_id = t.city_id
GROUP BY c.city_name
ORDER BY [%_contribution_to_total_trips] DESC
;


/*
==================================
Request 2: Monthly City-Level Trips Target Performance Report
==================================
*/

WITH monthly_trips_by_city AS (
	SELECT
		c.city_id,
		c.city_name,
		DATETRUNC(MONTH, t.date) AS month,
		COUNT(t.trip_id) AS actual_trips,
		mtt.total_target_trips AS target_trips
	FROM tripsdb.fact_trips AS t
	LEFT JOIN tripsdb.dim_city AS c
		ON c.city_id = t.city_id
	LEFT JOIN targetsdb.monthly_target_trips AS mtt
		ON t.city_id = mtt.city_id
		AND DATETRUNC(MONTH, t.date) = mtt.month
	GROUP BY c.city_id, c.city_name, DATETRUNC(MONTH, t.date), mtt.total_target_trips
)
SELECT
	city_name,
	month,
	actual_trips,
	target_trips,
	CASE
		WHEN actual_trips > target_trips THEN 'Above Target'
		ELSE 'Below Target'
	END AS performance_status,
	-- To calculate Percentage difference: ((|actual - expected|) / ((actual + expected) / 2)) * 100
	ROUND(100 * (ABS(actual_trips - target_trips) / CAST(((actual_trips + target_trips) / 2) AS FLOAT)), 2) AS [%_difference]
FROM monthly_trips_by_city
ORDER BY city_name, month
;