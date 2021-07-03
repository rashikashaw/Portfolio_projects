select * from PortfolioProject ..covid_deaths
where continent is not null 
order by 3,4

--select * from ..covid_vaccinations
--order by 3,4	

--Selecting data to use 
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
where continent is not null 
order by 1,2

--Looking at total cases vs total deaths= dealth rate
select location, date, total_cases, new_cases, total_deaths,
(total_deaths/total_cases)*100 as death_rate
from PortfolioProject..covid_deaths
where continent is not null 
where location like '%India%'
order by 1,2

--Looking at total cases vs population= Infected rate
select location, date, total_cases, population, 
(total_cases/population)*100 as population_infected_rate
from PortfolioProject..covid_deaths
where continent is not null 
where location like '%India%'
order by 1,2

--Looking at the countries highest infection rate compared to population
select location, population, max(total_cases) as highest_infected_count,
max((total_cases/population))*100 as population_infected_rate
from PortfolioProject..covid_deaths
where continent is not null 
group by location, population	
order by 4 desc

--Showing countries total deaths till date
select location,max(cast(total_deaths as int)) as total_deaths_count
from PortfolioProject..covid_deaths
where continent is not null 
group by location 
order by total_deaths_count desc

--Lets break thing down by continent

--Showing continents with highest death count
select continent,max(cast(total_deaths as int)) as total_deaths_count
from PortfolioProject..covid_deaths
where continent is not null 
group by continent 
order by total_deaths_count desc


--Global numbers:
select date, sum(new_cases) as total_new_cases, 
sum(cast(new_deaths as int)) as total_deathss, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage,
sum(total_deaths/total_cases) as death_percentage
from PortfolioProject..covid_deaths
where continent is not null 
group by date
order by 1,2

--Looking at total populations vs vaccinations
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vacc
	on dea.location =vacc.location
	and dea.date=vacc.date
where dea.continent is not null
order by 2,3


--Looking at total populations vs vaccinations
--CTE
With Popvsvacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vacc
	on dea.location =vacc.location
	and dea.date=vacc.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 from Popvsvacc

--TEMP TABLE
Drop table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vacc
	on dea.location =vacc.location
	and dea.date=vacc.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentagePopulationVaccinated

--Creating a view-- 
Drop view if exists PercentagePopulationVaccinated
Create view PercentagePopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vacc
	on dea.location =vacc.location
	and dea.date=vacc.date
where dea.continent is not null
--order by 2,3

select * from PercentagePopulationVaccinated