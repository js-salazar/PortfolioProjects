/*
Author: Jesús Andrey Salazar Araya
Queries used for PowerBI Project

*/

-- 1. Total Cases, Total Deaths and Death Percentage Globally of Covid-19

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidData.dbo.CovidDeaths
where continent is not null 
order by 1,2

-- 2. Total Death Count by Global Regions. 
--The included regions were plotted on a world map using Power BI."
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidData.dbo.CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International','High Income',
'Upper middle income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


-- 3. Countries with Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidData.dbo.CovidDeaths
WHERE continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Progression of % Population Infected by country over time

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidData.dbo.CovidDeaths
Group by Location, Population, date
order by location asc,date asc


-- 5. Total Population vs Vaccinations. New Vaccinations are per day

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

