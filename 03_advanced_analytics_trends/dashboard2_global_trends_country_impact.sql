/*
Dashboard 2 — COVID-19 Global Trends & Country-Level Impact Analysis

This SQL file contains advanced analytics queries used to build a Tableau dashboard
focused on global trends, rolling averages, and country-level infection and death metrics.

Data source: PortfolioProject..CovidDeaths
*/

-- 1. Global monthly cases vs deaths trend

SELECT
    DATEFROMPARTS(YEAR([date]), MONTH([date]), 1) AS MonthStart,
    SUM(COALESCE(new_cases, 0)) AS GlobalNewCases,
    SUM(COALESCE(CAST(new_deaths AS int), 0)) AS GlobalNewDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR([date]), MONTH([date]), 1)
ORDER BY MonthStart;

-- 2. Top 10 countries by COVID-19 death rate

SELECT TOP 10
    location,
    MAX(population) AS population,
    MAX(total_cases) AS total_cases,
    MAX(CAST(total_deaths AS int)) AS total_deaths,
    (MAX(CAST(total_deaths AS float)) / NULLIF(MAX(CAST(total_cases AS float)), 0)) * 100 AS DeathRatePercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(CAST(total_cases AS float)) >= 100000   -- avoids tiny countries skewing results
ORDER BY DeathRatePercent DESC;


-- 3. 7-day rolling average of new cases (selected countries)
SELECT
    location,
    [date],
    COALESCE(new_cases, 0) AS new_cases,
    AVG(CAST(COALESCE(new_cases, 0) AS float)) 
        OVER (PARTITION BY location ORDER BY [date] ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS NewCases_7DayAvg
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
  AND location IN ('United States', 'India', 'United Kingdom', 'Brazil')
ORDER BY location, [date];


-- 4. Infection rate vs death rate by country

SELECT
    location,
    MAX(population) AS population,
    MAX(CAST(total_cases AS float)) AS total_cases,
    MAX(CAST(total_deaths AS float)) AS total_deaths,
    (MAX(CAST(total_cases AS float)) / NULLIF(MAX(CAST(population AS float)), 0)) * 100 AS PercentPopInfected,
    (MAX(CAST(total_deaths AS float)) / NULLIF(MAX(CAST(total_cases AS float)), 0)) * 100 AS DeathRatePercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(CAST(total_cases AS float)) >= 100000
ORDER BY PercentPopInfected DESC;
