/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths
Where continent is not null
order by 3 ;

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date, total_cases,total_deaths,(total_deaths/total_cases) * 100as totaldeathpercentage
from coviddeaths
where location = 'India' 
and 
continent is not null;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,date,population, total_cases,(total_cases/population) * 100 as totalcasepercentage
from coviddeaths
where 
continent is not null;

-- Countries with Highest Infection Rate compared to Population

select Location,population, max(total_cases) as HighestInfectionCount, max(total_cases/population) * 100 as PercentPopulationInfected
from coviddeaths
group by location,population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

select Location, max(cast(total_deaths as signed)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc;
 
-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as signed)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

-- total deaths By day

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
Group By date
order by 1;

-- total Deaths till date

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null ;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as signed)) over (partition by vac.location order by vac.date) as Rollingpeoplevaccinated
from coviddeaths dea join 
covidvaccinations vac on
dea.location = vac.location AND
dea.date = vac.date
where dea.continent is not null ;
 

-- Using CTE to perform Calculation on Partition By in previous query

With cte as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as signed)) over (partition by vac.location order by vac.date) as Rollingpeoplevaccinated
from coviddeaths dea join 
covidvaccinations vac on
dea.location = vac.location AND
dea.date = vac.date
where dea.continent is not null 
 )

select *,(Rollingpeoplevaccinated/population)*100 as percentpeoplevaccinated
from CTE;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create temporary Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

