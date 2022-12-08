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

-- Global Numbers of New Cases, New Deaths, and Death Rate
SELECT
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths) * 1.0/ SUM(new_cases)) * 100 AS death_rate_per_case
FROM
	covid_deaths
WHERE
	location = 'World' AND
	new_cases <> 0
	
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

-- Inner Join between 'covid_deaths' table and 'covid_vaccinations' table
SELECT
	*
FROM
	covid_deaths d
INNER JOIN
	covid_vaccinations v
ON
	d.location = v.location AND
	d.date = v.date
	
-- Total Population vs Total Vaccinations
WITH population_vs_vaccination AS (
	SELECT
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(
		v.new_vaccinations
	) OVER (
		PARTITION BY 
			d.location
		ORDER BY
			d.date
	) AS rolling_total_vaccinations_per_location
	FROM
		covid_deaths d
	INNER JOIN
		covid_vaccinations v
	ON
		d.location = v.location AND
		d.date = v.date
	WHERE
		d.continent IS NOT NULL
		--AND d.location = 'Austria' AND v.new_vaccinations IS NOT NULL
)
SELECT
	*,
	(rolling_total_vaccinations_per_location * 1.0 / population) * 100 AS rolling_vaccinations_rate
FROM
	population_vs_vaccination
ORDER BY
	continent,
	location,
	date

-------------------------- TEMP TABLE CREATION STARTS --------------------------
CREATE TABLE IF NOT EXISTS public.populations_vaccinated
(
    continent character varying(25) COLLATE pg_catalog."default",
    location character varying(50) COLLATE pg_catalog."default",
    date character(10) COLLATE pg_catalog."default",
    population bigint,
    new_vaccinations int,
	rolling_total_vaccinations_per_location int
)

INSERT INTO populations_vaccinated
SELECT
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(
		v.new_vaccinations
	) OVER (
		PARTITION BY 
			d.location
		ORDER BY
			d.date
	) AS rolling_total_vaccinations_per_location
FROM
	covid_deaths d
INNER JOIN
	covid_vaccinations v
ON
	d.location = v.location AND
	d.date = v.date
-- WHERE d.continent IS NOT NULL -- Include continent only fields also
--------------------------- TEMP TABLE CREATION ENDS ---------------------------

--------------------------- VIEW CREATION STARTS ---------------------------
CREATE VIEW vpopulations_vaccinated AS
SELECT
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(
		v.new_vaccinations
	) OVER (
		PARTITION BY 
			d.location
		ORDER BY
			d.date
	) AS rolling_total_vaccinations_per_location
FROM
	covid_deaths d
INNER JOIN
	covid_vaccinations v
ON
	d.location = v.location AND
	d.date = v.date
---------------------------- VIEW CREATION ENDS ----------------------------

