SELECT
	date,
	FORMAT(date, 'MMM-yy') AS mmm_yy,
	DATENAME(week, date) AS week_no2,
	CASE
		WHEN DATENAME(weekday, date) = 'Friday' OR DATENAME(weekday, date) = 'Saturday' THEN 'weekend' -- Hotel Stakeholder says they consider Friday and Saturday as weekend while other days as weekday
		ELSE 'weekday'
	END AS day_type2
FROM hospitality.dim_date
;

SELECT *
FROM hospitality.dim_hotels;

SELECT *
FROM hospitality.dim_rooms;

SELECT *
FROM hospitality.fact_aggregated_bookings
WHERE successful_bookings = capacity
;



SELECT
	ratings_given,
	COUNT(ratings_given)
FROM hospitality.fact_bookings
GROUP BY ratings_given
ORDER BY ratings_given
;

SELECT
	booking_status,
	COUNT(*) AS count_status,
	ROUND(100 * (COUNT(*) / CAST(SUM(COUNT(*)) OVER() AS FLOAT)), 2) AS percent_count_status,
	SUM(revenue_generated) AS rev_gen,
	SUM(revenue_realized) AS actual_revenue,
	ROUND(100 * (SUM(revenue_realized) / CAST(SUM(SUM(revenue_realized)) OVER() AS FLOAT)), 2) AS percent_actual_revenue
FROM hospitality.fact_bookings
GROUP BY booking_status
;

SELECT
	COUNT(*) AS count_status,
	ROUND(100 * (COUNT(*) / CAST(SUM(COUNT(*)) OVER() AS FLOAT)), 2) AS percent_count_status,
	SUM(revenue_generated) AS rev_gen,
	SUM(revenue_realized) AS actual_revenue,
	ROUND(100 * (SUM(revenue_realized) / CAST(SUM(SUM(revenue_realized)) OVER() AS FLOAT)), 2) AS percent_actual_revenue
FROM hospitality.fact_bookings
;

-- Occupancy Rate
SELECT
	SUM(successful_bookings),
	SUM(capacity),
	100 * (SUM(successful_bookings) / CAST(SUM(capacity) AS FLOAT)) AS occupancy_rate
FROM hospitality.fact_aggregated_bookings
;