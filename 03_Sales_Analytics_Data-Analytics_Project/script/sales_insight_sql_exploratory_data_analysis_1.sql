/*
==================================
Sales Insight Portfolio Project
==================================
*/

USE sales
;

/*
----------------------------------
Assessing Tables and All Records
----------------------------------
*/

-- Customer Table: 3 columns (`customer_code`, `custmer_name` & `customer_type`) and 38 records
SELECT *
FROM sales.customers
;

-- Date Table: 5 columns (`date`, `cy_date`, `year`, `month_name` & `date_yy_mmm`) and 1126 records
SELECT *
FROM sales.date
;

SELECT
	COUNT(*)
FROM sales.date
;

-- Markets Table: 3 columns (`markets_code`, `markets_name` & `zone`) and 17 records
SELECT *
FROM sales.markets
;

-- Products Table: 2 columns (`product_code` & `product_type`) and 279 records
SELECT *
FROM sales.products
;

-- Transactions Table: 10 columns (`product_code`, `customer_code`, `market_code` `order_date`, `sales_qty`, `sales_amount`, `currency`, `profit_margin_percentage`, `profit_margin` & `cost_price`) and 150283 records
SELECT *
FROM sales.transactions
LIMIT 1000;

SELECT
	COUNT(*)
FROM sales.transactions
;
    


/*
==================================
	1. Data Quality Checks
==================================
*/

-- 1.1. Data Standardization & Consistency

-- There are 2 currency types in 4 formats: INR & USD. USD has to be converted to INR since we're dealing with local sales and we need to look for any leading or trailing spaces on the currency names.
SELECT DISTINCT
	currency,
    LENGTH(currency),
    COUNT(currency)
FROM sales.transactions
GROUP BY currency, LENGTH(currency)
;

SELECT DISTINCT
	market_code
FROM sales.transactions
WHERE market_code NOT IN (SELECT markets_code FROM sales.markets)
;

SELECT DISTINCT
	customer_code
FROM sales.transactions
WHERE customer_code NOT IN (SELECT customer_code FROM sales.customers)
;

-- Checking for negative or zero digits in sales_amount
-- We would have to exclude sales_amount with a negative or zero value. This may be due to bad data entry or some kind of malfunction at the source level.
SELECT
	*
FROM sales.transactions
WHERE sales_amount <= 0 
;

-- Checking for negative or zero digits in sales_qty
SELECT
	*
FROM sales.transactions
WHERE sales_qty <= 0 
;

SELECT DISTINCT
	customer_type
FROM sales.customers
;

-- There are 2 product types: Own Brand & Distribution
SELECT DISTINCT
	product_type
FROM sales.products
;


-- 1.2. Check for unwanted spaces in string values
	-- Customers table
SELECT
	custmer_name
FROM sales.customers
WHERE custmer_name != TRIM(custmer_name)
;

SELECT
	customer_type
FROM sales.customers
WHERE customer_type != TRIM(customer_type)
;

	-- Markets table
SELECT
	markets_name
FROM sales.markets
WHERE markets_name != TRIM(markets_name)
;

SELECT
	zone
FROM sales.markets
WHERE zone != TRIM(zone)
;

	-- Products table
SELECT
	product_type
FROM sales.products
WHERE product_type != TRIM(product_type)
;

	-- Transactions table
SELECT
	*
FROM sales.transactions
WHERE currency LIKE CONCAT('%', currency, '%')
;

    -- Checking for any unstandardized dates
SELECT
	*
FROM sales.transactions
WHERE order_date != TRIM(order_date)
;

SELECT
	*
FROM sales.date
WHERE date != TRIM(date)
;

-- 1.3. Checking for duplicate records
SELECT
	*
FROM (
	SELECT
		*,
        -- This identifies duplicates and flags them
		ROW_NUMBER() OVER (PARTITION BY product_code, customer_code, market_code, order_date, sales_qty, sales_amount ORDER BY order_date) AS flag
	FROM sales.transactions
) t
WHERE flag > 1 -- Flagged duplicates are filtered
;



/*
==================================
	2. Exploratory Data Analysis
==================================
*/

-- How many transactions are there per market?
SELECT
	m.markets_name,
    COUNT(*) AS transaction_count
FROM sales.transactions AS t
LEFT JOIN sales.markets AS m
	ON t.market_code = m.markets_code
WHERE t.currency != 'USD' -- To exclude any non-conforming records for now
GROUP BY m.markets_name
ORDER BY transaction_count DESC
;


-- Which markets generate the most revenue?
SELECT
	m.markets_name,
    SUM(t.sales_amount) AS total_revenue
FROM sales.transactions AS t
LEFT JOIN sales.markets AS m
	ON t.market_code = m.markets_code
WHERE t.currency != 'USD' -- To exclude any non-conforming records for now
GROUP BY m.markets_name
ORDER BY total_revenue DESC
;


-- Which customers generate the most sales?
SELECT
	c.custmer_name,
    SUM(t.sales_amount) AS total_sales
FROM sales.transactions AS t
LEFT JOIN sales.customers AS c
	ON t.customer_code = c.customer_code
WHERE t.currency != 'USD' -- To exclude any non-conforming records for now
GROUP BY c.custmer_name
ORDER BY total_sales DESC
;


-- Which transactions were in USD?
SELECT
	*
FROM sales.transactions
WHERE currency LIKE 'US%'
;


-- What was the annual and average revenue for each the year?
SELECT
	d.year,
    -- YEAR(t.order_date) AS `year`,
    SUM(t.sales_amount) AS total_sales,
    ROUND(AVG(t.sales_amount), 2) AS avg_sales
FROM sales.transactions AS t
LEFT JOIN sales.date AS d
	ON t.order_date = d.date
WHERE t.currency != 'USD'
GROUP BY d.year -- , YEAR(t.order_date)
-- ORDER BY total_sales DESC
;


/*
==================================
	3. Data Transformations
==================================
*/

WITH cleaned_table AS (
	SELECT
		*
	FROM (
		SELECT
			*,
			-- This identifies duplicates and flags them
			ROW_NUMBER() OVER (PARTITION BY product_code, customer_code, market_code, order_date, sales_qty, sales_amount ORDER BY order_date) AS flag
		FROM sales.transactions
		WHERE sales_amount > 0
	) t
	WHERE flag != 2
)

SELECT
	product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    currency,
    CASE
		WHEN currency LIKE 'US%' THEN sales_amount * 85.56
        ELSE sales_amount
    END AS norm_sales_amount
FROM cleaned_table
;

