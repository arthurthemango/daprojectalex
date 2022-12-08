-- Data fields to be used
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	covid_deaths
ORDER BY
	location,
	date;
	
-- Total Cases vs Total Deaths:
-- death percentages (likelihood of dying from covid)
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths * 1.0 / total_cases) * 100 AS death_rate
FROM
	covid_deaths
WHERE
	location like '%States%'
ORDER BY
	location,
	date;

-- Total Cases vs Population
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases * 1.0 / population) * 100 AS infection_rate
FROM
	covid_deaths
WHERE
	location like '%States%'
ORDER BY
	location,
	date;

-- Countries with Highest Infection Rate
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases * 1.0 / population) * 100) AS highest_infection_rate
FROM
	covid_deaths
WHERE
	total_cases IS NOT NULL AND
	population IS NOT NULLL AND
	continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY
	highest_infection_rate DESC;

-- Countries with Death Rate per Population
SELECT
	location,
	population,
	MAX(total_deaths) AS highest_death_count
FROM
	covid_deaths
WHERE
	total_cases IS NOT NULL AND
	total_deaths IS NOT NULL AND
	population IS NOT NULL AND
	continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY
	highest_death_count DESC;
	
-- Continent: 'location' field with null value in 'continent' field
-- e.g. | continent | location | ...
--      ----------------------------
--      |    [null] |     Asia | ...
--      |    [null] |   Europe | ...
--      |    [null] |   Africa | ...

-- Continents with Total Death Count
SELECT
	location,
	population,
	SUM(total_deaths) AS total_death_count
FROM
	covid_deaths
WHERE
	continent IS NULL
GROUP BY
	location,
	population
ORDER BY
	total_death_count DESC;

-- Continents with Highest Death Count
SELECT
	location,
	population,
	MAX(total_deaths) AS highest_death_count
FROM
	covid_deaths
WHERE
	continent IS NULL
GROUP BY
	location,
	population
ORDER BY
	highest_death_count DESC;

-- Global Numbers
SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths) * 1.0/ SUM(new_cases)) * 100 AS death_rate_per_case
	--total_cases,
	--total_deaths,
	--(total_deaths * 1.0 / total_cases) * 100 AS death_rate
FROM
	covid_deaths
WHERE
	continent IS NOT NULL AND
	new_cases IS NOT NULL AND
	new_deaths IS NOT NULL AND
	new_cases <> 0
GROUP BY
	date
ORDER BY
	date;



