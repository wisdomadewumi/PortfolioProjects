/*
MS SQL Server
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
		d.month_name,
		COUNT(t.trip_id) AS actual_trips,
		mtt.total_target_trips AS target_trips
	FROM tripsdb.fact_trips AS t
	LEFT JOIN tripsdb.dim_city AS c
		ON c.city_id = t.city_id
	LEFT JOIN targetsdb.monthly_target_trips AS mtt
		ON t.city_id = mtt.city_id
		AND DATETRUNC(MONTH, t.date) = mtt.month
	LEFT JOIN tripsdb.dim_date AS d
		ON d.date = t.date
		AND d.start_of_month = DATETRUNC(MONTH, t.date)
	GROUP BY c.city_id, c.city_name, DATETRUNC(MONTH, t.date), d.month_name, mtt.total_target_trips
), performance_gap AS (
	SELECT
		city_name,
		month,
		month_name,
		actual_trips,
		target_trips,
		CASE
			WHEN actual_trips > target_trips THEN 'Above Target'
			ELSE 'Below Target'
		END AS performance_status,
		-- To calculate Percentage difference: ((|actual - expected|) / ((actual + expected) / 2)) * 100
		ROUND(100 * (ABS(actual_trips - target_trips) / CAST(((actual_trips + target_trips) / 2) AS FLOAT)), 2) AS [%_difference]
	FROM monthly_trips_by_city
)

SELECT
	city_name,
	month_name,
	actual_trips,
	target_trips,
	performance_status,
	[%_difference]
FROM performance_gap
ORDER BY city_name
;


/*
==================================
Request 3: City-Level Repeat Passenger Trip Frequency Report
==================================
*/

WITH city_repeat_frequency AS (
	SELECT
		c.city_name,
		SUM(CASE
				WHEN r.trip_count = '2-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [2-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '3-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [3-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '4-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [4-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '5-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [5-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '6-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [6-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '7-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [7-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '8-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [8-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '9-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [9-Trips_n],
		SUM(CASE
				WHEN r.trip_count = '10-Trips' THEN r.repeat_passenger_count
				ELSE NULL
			END) AS [10-Trips_n],
		CAST(SUM(r.repeat_passenger_count) AS FLOAT) AS total_repeat_passengers
	FROM tripsdb.dim_repeat_trip_distribution AS r
	LEFT JOIN tripsdb.dim_city AS c
		ON c.city_id = r.city_id
	GROUP BY c.city_name
)
SELECT
	city_name,
	ROUND(100 * ([2-Trips_n] / total_repeat_passengers), 2) AS [2-Trips],
	ROUND(100 * ([3-Trips_n] / total_repeat_passengers), 2) AS [3-Trips],
	ROUND(100 * ([4-Trips_n] / total_repeat_passengers), 2) AS [4-Trips],
	ROUND(100 * ([5-Trips_n] / total_repeat_passengers), 2) AS [5-Trips],
	ROUND(100 * ([6-Trips_n] / total_repeat_passengers), 2) AS [6-Trips],
	ROUND(100 * ([7-Trips_n] / total_repeat_passengers), 2) AS [7-Trips],
	ROUND(100 * ([8-Trips_n] / total_repeat_passengers), 2) AS [8-Trips],
	ROUND(100 * ([9-Trips_n] / total_repeat_passengers), 2) AS [9-Trips],
	ROUND(100 * ([10-Trips_n] / total_repeat_passengers), 2) AS [10-Trips]
FROM city_repeat_frequency
;


/*
==================================
Request 4: Identify Cities with Highest and Lowest Total New Passengers
==================================
*/

WITH city_passengers AS (
	SELECT
		c.city_name,
		SUM(ps.new_passengers) AS total_new_passengers,
		RANK() OVER (ORDER BY SUM(ps.new_passengers) DESC) AS new_passenger_rank
	FROM tripsdb.fact_passenger_summary AS ps
	LEFT JOIN tripsdb.dim_city AS c
		ON c.city_id = ps.city_id
	GROUP BY c.city_name
)

SELECT 
	city_name,
	total_new_passengers,
	-- Identifying and listing Top and Bottom 3 cities with highest and lowest new passengers
	CASE
		WHEN new_passenger_rank <= FIRST_VALUE(new_passenger_rank) OVER (ORDER BY new_passenger_rank ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) + 2 THEN 'Top 3'
		WHEN new_passenger_rank >= LAST_VALUE(new_passenger_rank) OVER (ORDER BY new_passenger_rank ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) - 2 THEN 'Bottom 3'
		ELSE CAST(new_passenger_rank AS NVARCHAR)
	END AS city_category
FROM city_passengers
ORDER BY total_new_passengers DESC
;


/*
==================================
Request 5: Identify Month with Highest Revenue for Each City
==================================
*/

WITH highest_revenue_month AS (
	SELECT
		c.city_name,
		d.month_name AS month,
		SUM(t.fare_amount) AS revenue,
		SUM(SUM(t.fare_amount)) OVER (PARTITION BY c.city_name) AS total_revenue
	FROM tripsdb.fact_trips AS t
	LEFT JOIN tripsdb.dim_city AS c
		ON c.city_id = t.city_id
	LEFT JOIN tripsdb.dim_date AS d
		ON d.date = t.date
		AND d.start_of_month = DATETRUNC(MONTH, t.date)
	GROUP BY c.city_name, d.month_name

), flag_max_revenue AS (
	SELECT
		*,
		ROUND(100 * revenue / CAST(total_revenue AS FLOAT), 2) AS percentage_contribution,
		RANK() OVER (PARTITION BY city_name ORDER BY revenue DESC) AS max_revenue_rank
	FROM highest_revenue_month
)

SELECT
	city_name,
	month AS highest_revenue_month,
	revenue,
	percentage_contribution
FROM flag_max_revenue
WHERE max_revenue_rank = 1
ORDER BY revenue DESC
;


/*
==================================
Request 6: Repeat Passenger Rate Analysis
==================================
*/


WITH passenger_report AS (
	SELECT
		c.city_name,
		d.month_name,
		d.start_of_month AS month,
		ps.total_passengers,
		ps.repeat_passengers,
		ROUND(100 * (ps.repeat_passengers / CAST(ps.total_passengers AS FLOAT)), 2) AS monthly_repeat_passenger_rate,
		ROUND(100 * (SUM(ps.repeat_passengers) OVER(PARTITION BY city_name) / CAST(SUM(ps.total_passengers) OVER(PARTITION BY city_name) AS FLOAT)), 2) AS city_repeat_passenger_rate
	FROM tripsdb.fact_passenger_summary AS ps
	LEFT JOIN tripsdb.dim_city AS c
		ON c.city_id = ps.city_id
	LEFT JOIN tripsdb.dim_date AS d
		ON d.start_of_month = ps.month
	GROUP BY c.city_name, d.month_name, d.start_of_month, total_passengers, repeat_passengers
)

SELECT
	city_name,
	month,
	total_passengers,
	repeat_passengers,
	monthly_repeat_passenger_rate,
	city_repeat_passenger_rate
FROM passenger_report
ORDER BY city_name, month
;