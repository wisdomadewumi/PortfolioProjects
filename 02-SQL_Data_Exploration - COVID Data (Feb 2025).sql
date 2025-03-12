/*
Covid 19 Exploratory Data Analysis

Skills used: Aggregate Functions, Window Functions, CTEs, Temp Tables, Subqueries, Creating Views, Converting Data Types

The below datasets are of Covid19 for various metrics spanning 6 continents between 2020-01-01 and 2025-02-23
*/

USE PortfolioProject -- Database name
;

-- Covid Deaths Dataset Overview

SELECT TOP 100
	MAX(date)
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
;

-- Selecting initial data of interest

SELECT
	country,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM dbo.compact_covid19
ORDER BY country, date
;


-- Task 1: What was the percentage of Covid deaths in Benin and Nigeria?
-- i.e. what is the likelihood of dying if one contracts Covid in that country

SELECT
	country,
	date,
	total_cases,
	total_deaths,
	100 * total_deaths / CAST(NULLIF(total_cases,0) AS FLOAT) AS death_percent
FROM dbo.compact_covid19
WHERE country = 'Benin'
OR country = 'Nigeria'
AND continent IS NOT NULL
ORDER BY country, date
;


-- Task 2: What percentage of the population contracted or is infected with covid? i.e. Infection Rate

SELECT
	country,
	date,
	population,
	total_cases,
	100 * total_cases / CAST(NULLIF(population,0) AS FLOAT) AS covid_case_percent
FROM dbo.compact_covid19
WHERE country = 'Benin'
OR country = 'Nigeria'
AND continent IS NOT NULL
ORDER BY country, date
;


-- Task 3: Which countries have the highest infection count per population as at 2025-02-23?

SELECT
	country,
	population,
	MAX(total_cases) AS highest_total_cases,
	ROUND(100 * MAX(total_cases / CAST(population AS FLOAT)),2) AS population_infection_rate
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
GROUP BY country, population
ORDER BY population_infection_rate DESC
;


-- Task 4: Which countries have the highest death rate as at 2025-02-23?

SELECT
	country,
	population,
	MAX(total_deaths) AS highest_total_deaths,
	ROUND(100 * MAX(total_deaths / CAST(population AS FLOAT)),2) AS population_death_rate
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
AND population IS NOT NULL
AND country IS NOT NULL
GROUP BY country, population
ORDER BY population_death_rate DESC
;


-- Task 5: Which countries have the highest death count as at 2025-02-23?

SELECT
	country,
	MAX(total_deaths) AS total_death_count
FROM dbo.compact_covid19
WHERE country IS NOT NULL
AND continent IS NOT NULL
GROUP BY country
ORDER BY total_death_count DESC
;


-- Task 6: Which continents have the highest death count as at 2025-02-23?

SELECT
	continent,
	SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC
;

-- Create View to store result of Task 6 for later

CREATE VIEW ContinentDeathCount AS
(
	SELECT
		continent,
		SUM(CAST(new_deaths AS INT)) AS total_death_count
	FROM dbo.compact_covid19
	WHERE continent IS NOT NULL
	GROUP BY continent
);


-- Task 7: What are the number of cases, number of deaths and death percentage worldwide?

SELECT
	SUM(new_cases) AS total_world_cases,
	SUM(new_deaths) AS total_world_deaths,
	ROUND(100 * SUM(new_deaths) / SUM(CAST (new_cases AS FLOAT)),2) AS world_death_percent
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
;


-- Task 8: What percentage of population has received at least one Covid vaccine?
-- The column new_vaccinations shows the number of new vaccinations per day.

SELECT
	continent,
	country,
	date,
	population,
	new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY country ORDER BY CONVERT(VARCHAR(50),country), date) AS cumul_people_vaccinated
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
;


-- Using a CTE, we'd house the rolling/cumulative total of new vaccinations from first day of vaccinations till 2025-02-23, if applicable, then query the CTE for the required results

WITH VaccinatedPopulation AS
(
	SELECT
		continent,
		country,
		date,
		population,
		new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY country ORDER BY CONVERT(VARCHAR(50),country), date) AS cumul_people_vaccinated
	FROM dbo.compact_covid19
	WHERE continent IS NOT NULL
)

SELECT
	country,
	population,
	MAX(cumul_people_vaccinated) AS total_people_vaccinated,
	MAX(ROUND(100 * cumul_people_vaccinated / CAST(population AS FLOAT),2)) AS population_percent_vaccinated
FROM VaccinatedPopulation
GROUP BY country, population
ORDER BY population_percent_vaccinated DESC
;


-- Using Temp Table to run calculations on PARTITION BY in Task 8

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	Cumulative_People_Vaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
	SELECT
		continent,
		country,
		date,
		population,
		new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY country ORDER BY CONVERT(VARCHAR(50),country), date) AS cumul_people_vaccinated
	FROM dbo.compact_covid19
	WHERE continent IS NOT NULL
;


-- Simple query on Temp Table

SELECT
	*,
	ROUND(100 * Cumulative_People_Vaccinated / CAST(Population AS FLOAT),2) AS population_percent_vaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location, Date
;


-- Creating a View to store data for later Visualizations
CREATE VIEW VaccinatedPopulationPercentage AS
(
	SELECT
		continent,
		country,
		date,
		population,
		new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY country ORDER BY CONVERT(VARCHAR(50),country), date) AS cumul_people_vaccinated
	FROM dbo.compact_covid19
	WHERE continent IS NOT NULL
);


-- Task 9: What are the total number of monthly Covid cases and deaths?

SELECT
	country,
	DATETRUNC(MONTH, date) AS Months,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
GROUP BY country, DATETRUNC(MONTH, date)
ORDER BY country, Months
;


-- Task 10: Which country had the 5th highest death rate from Covid?

SELECT *
FROM
(
	SELECT
		country,
		population,
		SUM(new_deaths) AS total_deaths,
		100 * SUM(new_deaths) / CAST(population AS FLOAT) AS percent_deaths,
		RANK() OVER (ORDER BY 100 * SUM(new_deaths) / CAST(population AS FLOAT) DESC) AS rank_percent_deaths
	FROM dbo.compact_covid19
	WHERE continent IS NOT NULL
	GROUP BY country, population
) t
WHERE rank_percent_deaths = 5
;


-- Task 11: Which countries rank in the top 10 highest Covid vaccinated population?

WITH CovidVaccinatedPop AS
(
	SELECT
		country,
		population,
		SUM(new_vaccinations) AS total_vaccinations,
		100 * SUM(new_vaccinations) / CAST(population AS FLOAT) AS vaccinated_pop
	FROM dbo.compact_covid19
	WHERE continent IS NOT NULL
	GROUP BY country, population
)
SELECT TOP 10
	*
FROM CovidVaccinatedPop
--WHERE vaccinated_pop < 100
ORDER BY vaccinated_pop DESC


/*
Shout out to: Alex The Analyst
*/