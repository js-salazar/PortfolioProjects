-- Author: Jesús Andrey Salazar Araya
--Data as of June 2024

SELECT *
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4



--Select Data to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM CovidData.dbo.CovidDeaths
WHERE location like '%costa rica%' AND continent is not null
ORDER BY 1,2

--Total Cases vs Population
--Answers the % of population that got Covid
SELECT Location, date,population, total_cases, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS Percent_Population_Infected
FROM CovidData.dbo.CovidDeaths
WHERE location like '%costa rica%'  AND continent is not null
ORDER BY 1,2


--Countries with Highest Infection Rate compared to population
SELECT Location,population ,MAX(CAST(total_cases AS int)) AS Highest_Infection_Count,MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))) * 100 AS Percent_Population_Infected
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location,population
ORDER BY Percent_Population_Infected DESC


--Countries with Highest Death Count per population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Exploring deaths by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null

ORDER BY 1,2

--Looking at Total Population vs Vaccinations. New Vaccinations per day
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
AS(

Select DEA.continent, DEA.location, CAST(DEA.date AS DATE), DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (Partition by DEA.location ORDER BY DEA.Location, CAST(DEA.date AS DATE)) as RollingPeopleVaccinated

FROM CovidData.dbo.CovidDeaths AS DEA
JOIN CovidData.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
--ORDER BY 2,3

)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM PopvsVac

