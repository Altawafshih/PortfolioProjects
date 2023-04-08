--/* 
--Covid 19 data Exploration
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
--/*
select * 
from CovidDeaths
order by 3,4

select * 
from CovidVaccinations
order by 3,4 
---- Select Data that we are going to be starting with
select Location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
------------------------------------------------------------------------------------------------------------
Select Location, date, total_cases, (total_deaths / total_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%' 
--and continent is not null 
order by 1,2
----------------------------------------------------------------------------------------------
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
order by 1,2
------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Infection Rate compared to Population
select Location,Population,max(total_cases) as HighestInfectionCount,MAX(total_cases/Population)*100 as PercentPopulationInfected
from CovidDeaths
group by location,population
order by PercentPopulationInfected desc
-----------------------------------------------------------------------------------
--Countries with Highest Death Count per Population
select Location,MAX(CAST(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by Location
order by Totaldeathcount desc
------------------------------------------------------------------------------------------
-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
where continent is not null 
Group by continent
order by TotalDeathCount desc
------------------------------------------------------------------------------------------------
-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
--------------------------------------------------------------------------------------------------------------------------------------
-- looking at total Population vs Vaccinations
select dea.continent,dea.location,dea.date,population
from CovidDeaths as dea
inner join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
-------------------------------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population
, SUM(CONVERT(int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
-----------------------------------------------------------------------------------------------------------------------
-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
