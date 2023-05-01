--select *
--from covid..CovidDeaths
--order by 3,4

--select *
--from covid..CovidVaccinations
--order by 3,4


select location, date, total_cases, total_deaths, new_cases, population
from covid..CovidDeaths
order by 1,2

--Total Cases vs Total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covid..CovidDeaths
order by 1,2

--Total Cases vs Total deaths in INDIA
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covid..CovidDeaths
where location like '%india%'
order by 1,2

--Total Cases vs Population
--percentage of population inffected with covid in canada
select location, date, total_cases,population, (total_cases/population)*100 as Percentpopulationinffected
from covid..CovidDeaths
where location like '%canada%'
order by 1,2

--Highest infection per country
select location,population, max(total_cases) as Highestinfectedcount, max((total_cases/population))*100 as Percentpopulationinffected
from covid..CovidDeaths
where continent is not null
group by location,population
order by Percentpopulationinffected desc

-- Each countries highest death count vs population
select location, max(cast(total_deaths as int)) as highestdeathcount
from covid..CovidDeaths
where continent is not null
group by location
order by highestdeathcount desc

-- death count by CONTINENT
select location, max(cast(total_deaths as int)) as highestdeathcount
from covid..CovidDeaths
where continent is null
group by location
order by highestdeathcount desc

--continents with highest death count
select continent, max(cast(total_deaths as int)) as highestdeathcount
from covid..CovidDeaths
where continent is not null
group by continent
order by highestdeathcount desc

--Global Numbers 
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid..CovidDeaths
where continent is not null
order by 1,2

-- Global Numbers per day
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Joining two tables
select *
from covid..Coviddeaths dea
join covid..CovidVaccinations vac
  on dea.location=vac.location and dea.date=vac.date
order by 3,4

--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingcountofvaccinations
from covid..Coviddeaths dea
join covid..CovidVaccinations vac
  on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- using CTE

with Populationvsvaccinations (continent, location, date, population, new_vaccinations, rollingcountofvaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingcountofvaccinations
from covid..Coviddeaths dea
join covid..CovidVaccinations vac
  on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select * , (rollingcountofvaccinations/population)*100 as Vaccination_percentage
from Populationvsvaccinations


-- Creating Views
 create view populationvaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingcountofvaccinations
from covid..Coviddeaths dea
join covid..CovidVaccinations vac
  on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
 
create view globalnumber as
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid..CovidDeaths
where continent is not null
group by date

