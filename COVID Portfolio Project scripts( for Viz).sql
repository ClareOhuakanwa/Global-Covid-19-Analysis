--select *
--from CovidVaccinations
--order by location, date


--select the Data to be used 

select *
from CovidDeaths
order by location, date

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by location, date

--Total Cases Vs Total Deaths
--Shows  the likelihood of dying if you contract Covid in the UK

select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null and location like '%Kingdom%'
order by location, date

--Total Cases Vs Population
--Shows the percentage of population in the UK infected by Covid

select location, date, population, total_cases, (total_cases / population)*100  as PopulationRateInfected
from CovidDeaths
where continent is not null and location = 'United Kingdom'
order by location, date

--Countries with the Highest Infection Rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PopulationRateInfected
from CovidDeaths
where continent is not null
group by location, population
order by PopulationRateInfected desc

--Continent with the Highest Death count

select location, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is null
group by location
order by DeathCount desc

select continent, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by continent
order by DeathCount desc

--Countries with the Highest Death Count per population

select location, Max(cast(total_deaths as int )) as DeathCount
from CovidDeaths
where continent is not null
group by location
order by DeathCount desc

--Global Numbers per day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

--Vaccinations

select *
from CovidVaccinations

--Total Population VS Vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingVaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by location, date

--Using CTE

with populationvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingVaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by location, date
select *, (RollingVaccinations/population)*100
from populationvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinations numeric,
RollingVaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
	dea.date) as RollingVaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingVaccinations/population)*100
from #PercentPopulationVaccinated

--Creating views for Visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingVaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

create view DeathCountbyContinent as 
select continent, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by continent

create view GlobalNumbers as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null