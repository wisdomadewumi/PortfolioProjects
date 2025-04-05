/*
==================================
Codebasics SQL Challenge
==================================

Domain:  Consumer Goods | Function: Executive Management

Atliq Hardwares (imaginary company) is one of the leading computer hardware producers in India and well expanded in other countries too.

However, the management noticed that they do not get enough insights to make quick and smart data-informed decisions. They want to expand their data analytics team by adding several junior data analysts. Tony Sharma, their data analytics director wanted to hire someone who is good at both tech and soft skills. Hence, he decided to conduct a SQL challenge which will help him understand both the skills.

*/

USE gdb023;

-- Tasks to complete

/*
==================================
Request 1: Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.
==================================
*/

SELECT DISTINCT
	customer,
    region,
    market
FROM dim_customer
WHERE customer = 'Atliq Exclusive'
	AND region = 'APAC'
;
-- "Atliq Exclusive" is active in 9 markets/countries in the APAC region


/*
==================================
Request 2: What is the percentage of unique product increase in 2021 vs. 2020?
The final output contains these fields:
	unique_products_2020
	unique_products_2021
	percentage_chg
==================================
*/

WITH unique_products_year AS (
	SELECT
		COUNT(DISTINCT
			CASE
				WHEN fiscal_year = '2020' THEN product_code
				ELSE NULL
			END
            ) AS unique_products_2020,
		COUNT(DISTINCT
			CASE
				WHEN fiscal_year = '2021' THEN product_code
				ELSE NULL
			END
            ) AS unique_products_2021
	FROM fact_sales_monthly
)
SELECT
	*,
    ROUND(100 * ((unique_products_2021 - unique_products_2020) / unique_products_2020), 2) AS percentage_chg
FROM unique_products_year
;
-- We have a 36.33% increase in unique products from last year.


/*
==================================
Request 3: Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.
The final output contains
2 fields:
	segment
	product_count
==================================
*/

SELECT
	segment,
	COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC
;
-- There are 6 product segments with Notebook, Accessories and Peripherals in the Top 3.


/*
==================================
Request 4: Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?
The final output contains these fields:
	segment
	product_count_2020
	product_count_2021
	difference
==================================
*/

WITH product_count AS (
	SELECT
		p.segment AS segment,
		COUNT(DISTINCT
			CASE
				WHEN sm.fiscal_year = '2020' THEN p.product_code
				ELSE NULL
			END
			) AS product_count_2020,
		COUNT(DISTINCT
			CASE
				WHEN sm.fiscal_year = '2021' THEN p.product_code
				ELSE NULL
			END
			) AS product_count_2021
	FROM dim_product AS p
	INNER JOIN fact_sales_monthly AS sm
		ON p.product_code = sm.product_code
	GROUP BY p.segment
)
SELECT
	segment,
    product_count_2020,
    product_count_2021,
    product_count_2021 - product_count_2020 AS difference
FROM product_count
GROUP BY segment
ORDER BY difference DESC
;


/*
==================================
Request 5: Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields:
	product_code
	product
	manufacturing_cost
==================================
*/

-- Query for product with highest manufacturing cost
SELECT
    p.product_code,
    p.product,
    mc.manufacturing_cost
FROM dim_product AS p
INNER JOIN fact_manufacturing_cost AS mc
	ON p.product_code = mc.product_code
WHERE mc.manufacturing_cost = (SELECT MAX(mc1.manufacturing_cost) FROM fact_manufacturing_cost AS mc1)

UNION ALL

-- Query for product with lowest manufacturing cost
SELECT
    p.product_code,
    p.product,
    mc.manufacturing_cost
FROM dim_product AS p
INNER JOIN fact_manufacturing_cost AS mc
	ON p.product_code = mc.product_code
WHERE mc.manufacturing_cost = (SELECT MIN(mc1.manufacturing_cost) FROM fact_manufacturing_cost AS mc1)
;


/*
==================================
Request 6: Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
The final output contains these fields:
	customer_code
	customer
	average_discount_percentage
==================================
*/

SELECT
	pid.customer_code,
    c.customer,
    AVG(pid.pre_invoice_discount_pct) AS average_discount_percentage
FROM fact_pre_invoice_deductions AS pid
LEFT JOIN dim_customer AS c
	ON c.customer_code = pid.customer_code
WHERE c.market = 'India' AND pid.fiscal_year = '2021'
GROUP BY pid.customer_code, c.customer
ORDER BY average_discount_percentage DESC
LIMIT 5
;


/*
==================================
Request 7: Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.
The final report contains these columns:
	Month
	Year
	Gross sales Amount
==================================
*/

SELECT
	`month`,
    `year`,
    ROUND(SUM(daily_gross_sales_amount), 2) AS gross_sales_amount
FROM (
	SELECT
		MONTH(sm.date) AS `month`,
		YEAR(sm.date) AS `year`,
		sm.sold_quantity * gp.gross_price AS daily_gross_sales_amount
	FROM fact_sales_monthly AS sm
	LEFT JOIN fact_gross_price AS gp
		ON gp.product_code = sm.product_code
	LEFT JOIN dim_customer AS c
		ON c.customer_code = sm.customer_code
	WHERE c.customer = 'Atliq Exclusive'
) t
GROUP BY `month`, `year`
ORDER BY `year`,  `month`
;


/*
==================================
Request 8: In which quarter of 2020, got the maximum total_sold_quantity?
The final output contains these fields sorted by the total_sold_quantity:
	Quarter
	total_sold_quantity
==================================
*/

SELECT
	QUARTER(sm.date) AS `quarter`,
	SUM(sm.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS sm
WHERE YEAR(sm.date) = '2020'
GROUP BY QUARTER(sm.date)
ORDER BY total_sold_quantity DESC
LIMIT 1
;


/*
==================================
Request 9: Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
The final output contains these fields:
	channel
	gross_sales_mln
	percentage
==================================
*/

WITH gross_sales AS (
	SELECT
		c.channel AS channel,
		sm.sold_quantity * gp.gross_price AS gross_sales_2021
	FROM fact_sales_monthly AS sm
	LEFT JOIN dim_customer AS c
		ON c.customer_code = sm.customer_code
	LEFT JOIN fact_gross_price AS gp
		ON sm.product_code = gp.product_code
	WHERE gp.fiscal_year = '2021'
)
SELECT
	channel,
    SUM(gross_sales_2021) / 1000000 AS gross_sales_mln, -- Unit is in millions
    ROUND(100 * SUM(gross_sales_2021) / SUM(SUM(gross_sales_2021)) OVER (), 2) AS percentage
FROM gross_sales
GROUP BY channel
ORDER BY percentage DESC
;
-- The retailer channel brought in more gross sales in the fiscal year 2021


/*
==================================
Request 10: Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?
The final output contains these fields:
	division
	product_code
	product
	total_sold_quantity
	rank_order
==================================
*/

WITH top_3_ranking AS (
	SELECT
		p.division,
		p.product_code,
		p.product,
		SUM(sm.sold_quantity) AS total_sold_quantity,
        RANK() OVER (PARTITION BY p.division ORDER BY SUM(sm.sold_quantity) DESC) AS rank_order
	FROM dim_product AS p
	LEFT JOIN fact_sales_monthly AS sm
		ON p.product_code = sm.product_code
	WHERE sm.fiscal_year = '2021'
	GROUP BY p.division, p.product_code, p.product
)
SELECT
	*,
    rank_order
FROM top_3_ranking
WHERE rank_order <= 3
ORDER BY division, rank_order
;