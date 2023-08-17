SELECT *
FROM PortfolioCovid..Covid_Deaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioCovid..Covid_Vaccinations
--ORDER BY 3, 4

--Select Data That We Are Going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCovid..Covid_Deaths
ORDER BY 1, 2

--Looking at the total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPercentage
FROM PortfolioCovid..Covid_Deaths
ORDER BY 1, 2

--Shows likelihood of dying if you contact covid in your country (Sri lanka)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPercentage
FROM PortfolioCovid..Covid_Deaths
WHERE location LIKE 'sri%'
ORDER BY 1, 2

--Looking at total cases vs population
--Shows likelihood of getting covid (Sri lanka)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infectionPercentage
FROM PortfolioCovid..Covid_Deaths
WHERE location LIKE 'sri%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX(total_cases/population)*100 AS infectionPercentage
FROM PortfolioCovid..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infectionPercentage DESC

--Showing continents with highest death count per population
SELECT location, population, MAX(total_deaths) AS highestDeathCount
FROM PortfolioCovid..Covid_Deaths
WHERE continent IS NULL AND location NOT IN('World','High income','Upper middle income','Lower middle income','European Union','Low income') OR location='australia'
GROUP BY location, population
ORDER BY highestDeathCount DESC 

--Showing countries with highest death count per population 
SELECT location, population, MAX(total_deaths) AS highestDeathCount
FROM PortfolioCovid..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highestDeathCount DESC

--Showing populations with highest death count per population with respect to income level of location
SELECT location, population, MAX(total_deaths) AS highestDeathCount
FROM PortfolioCovid..Covid_Deaths
WHERE continent IS NULL AND location NOT IN('World','Europe','Asia','North America','Africa','Oceania','South America','European Union')
GROUP BY location, population
ORDER BY highestDeathCount DESC

--Showing highest death count per population of world and europian union
SELECT location, population, MAX(total_deaths) AS highestDeathCount
FROM PortfolioCovid..Covid_Deaths
WHERE continent IS NULL AND location NOT IN('High income','Upper middle income','Lower middle income','Low income','Europe','Asia','North America','Africa','Oceania','South America')
GROUP BY location, population
ORDER BY highestDeathCount DESC

--Looking at global numbers each day
SELECT date, SUM(new_deaths) AS totalDeaths, SUM(new_cases) AS totaNewCases, (SUM(new_deaths)/SUM(new_cases))*100 AS deathPercentage
FROM PortfolioCovid..Covid_Deaths
WHERE continent IS NOT NULL 
GROUP BY date
HAVING SUM(new_cases)<>0
ORDER BY date

--Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinations
FROM PortfolioCovid..Covid_Deaths AS dea
JOIN PortfolioCovid..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Ue CTE
WITH popvsvsc (continent, location, date, population, new_vaccinations, rollingPeopleVaccinations)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinations
FROM PortfolioCovid..Covid_Deaths AS dea
JOIN PortfolioCovid..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (rollingPeopleVaccinations/population)*100
FROM popvsvsc


--Temp table

DROP TABLE IF EXISTS #percetagePopulationVaccinated
CREATE TABLE #percetagePopulationVaccinated
(
continent varchar(MAX),
location varchar(50),
date date,
population float,
new_vaccinations float,
rollingPeopleVaccinations float
)

INSERT INTO #percetagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinations
FROM PortfolioCovid..Covid_Deaths AS dea
JOIN PortfolioCovid..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * , (rollingPeopleVaccinations/population)*100
FROM #percetagePopulationVaccinated


--Creating view to store data for later visualizations
DROP VIEW IF EXISTS percetagePopulationVaccinated
CREATE VIEW percetagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinations
FROM PortfolioCovid..Covid_Deaths AS dea
JOIN PortfolioCovid..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM percetagePopulationVaccinated