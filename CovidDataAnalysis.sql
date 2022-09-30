Select *
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3, 4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--LOOKING AT TOTAL CASES vs TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN ANY COUNTRY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%BANGLADESH%'
ORDER BY 1,2


--- LOOKING AT TOTAL CASES vs POPULATION
--- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_infected
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%BANGLADESH%'
ORDER BY 1,2


--- LOOKING TO AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, max(total_cases) AS Highest_infection, MAX((total_cases/population))*100 AS percentpopulation_infected
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%BANGLADESH%'
where continent is not null
group by location, population
ORDER BY percentpopulation_infected desc


--showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%BANGLADESH%'
where continent is not null
group by location
ORDER BY TotalDeathCount desc

--showing death count by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%BANGLADESH%'
where continent is null
group by location
ORDER BY TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2


--total percentage vs Vaccinations
--shows percentage of population that has receive at least one covid vaccine

--use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)


Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--temp table
drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select *, (RollingPeopleVaccinated/Population)*100
from #PercentpopulationVaccinated



--creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



Select * 
From PercentPopulationVaccinated


Create view DEATHCOUNT as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%BANGLADESH%'
where continent is null
group by location
--ORDER BY TotalDeathCount desc

Create view INFECTEDCNT as 
SELECT location, population, max(total_cases) AS Highest_infection, MAX((total_cases/population))*100 AS percentpopulation_infected
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%BANGLADESH%'
where continent is not null
group by location, population
--ORDER BY percentpopulation_infected desc

Create view HIGHESTDEATH as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%BANGLADESH%'
where continent is not null
group by location
--ORDER BY TotalDeathCount desc