/*
Tableau Dashboard Tables

This Coivd19 dataset collects various metrics spanning 6 continents between 2020-01-01 and 2025-02-23
*/

-- Table 1
-- Task 7: What are the number of cases, number of deaths and death percentage worldwide?

SELECT
	SUM(new_cases) AS total_world_cases,
	SUM(new_deaths) AS total_world_deaths,
	ROUND(100 * SUM(new_deaths) / SUM(CAST (new_cases AS FLOAT)),2) AS world_death_percent
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
;


-- Table 2
-- Task 6: Which continents have the highest death count as at 2021-04-30?

SELECT
	continent,
	SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM dbo.compact_covid19
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC
;


-- Table 3
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


-- Table 4

SELECT
	country,
	population,
	date,
	MAX(total_cases) AS highest_infection_count,
	100 * MAX(total_cases / CAST(population AS FLOAT)) AS percent_population_infected
FROM dbo.compact_covid19
-- WHERE continent IS NOT NULL
GROUP BY country, population, date
ORDER BY percent_population_infected DESC
;