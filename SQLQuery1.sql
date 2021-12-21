select * from PortfolioProjectDatabase..CovidDeaths

select * from PortfolioProjectDatabase..CovidVaccinations
order by 3,4

--Select Data That we are goin to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectDatabase..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--likelihood of dying from covid in a specific country
Select Location, date, total_cases, total_deaths, new_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectDatabase..CovidDeaths
where location like '%lebanon%'
order by 1,2

--Looking at the Total Cases vs Population
-- Shows what percentage of the population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as Percentage_Positive
From PortfolioProjectDatabase..CovidDeaths
where location like '%lebanon%'
order by 1,2

--Countries with the highest infection rate compared to population
Select Location, max(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as Percentage_Positive
From PortfolioProjectDatabase..CovidDeaths
group by location, population
order by Percentage_Positive desc

--Countries with the highest death rate per population
Select location, max(cast(total_deaths as int)) as HighestDeaths 
From PortfolioProjectDatabase..CovidDeaths
where continent is not null
group by location
order by HighestDeaths desc


--LETS BREAK THINGS DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as HighestDeaths
From PortfolioProjectDatabase..CovidDeaths
where continent is not null
group by continent
order by HighestDeaths desc

--Global Numbers
select date, sum(new_cases) as TotalGlobalDailyCases, SUM(cast(new_deaths as int)) as TotalGlobalDailyDeathCases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjectDatabase..CovidDeaths
where continent is not null 
group by date
order by 1,2

--selecting new vaccines per day in each country
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjectDatabase..CovidVaccinations vac
Join PortfolioProjectDatabase..CovidDeaths dea
on dea.location= vac.location
where dea.continent is not null
and dea.date= vac.date
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.Date) as CUMSUM_Vaccines 
From PortfolioProjectDatabase..CovidVaccinations vac
Join PortfolioProjectDatabase..CovidDeaths dea
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--USE CTE(to calculte PercentPopulationVaccinated)

with PopulationVSvaccination(Continent, Location, Date, Population, New_Vaccinations, CUMSUM_Vaccines)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.Date) as CUMSUM_Vaccines 
from PortfolioProjectDatabase..CovidVaccinations vac
Join PortfolioProjectDatabase..CovidDeaths dea
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
)
Select *, (CUMSUM_Vaccines/Population)*100 as PercentPopulationVaccinated
from PopulationVSvaccination


--TEMP TABLE (same result as above but using temp table)
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
CUMSUM_Vaccines numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.Date) as CUMSUM_Vaccines 
from PortfolioProjectDatabase..CovidVaccinations vac
Join PortfolioProjectDatabase..CovidDeaths dea
	on dea.location= vac.location
	and dea.date= vac.date
Select *, (CUMSUM_Vaccines/Population)*100 PercentPopulationVaccinated 
From #PercentPopulationVaccinated


--creating views to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.Date) as CUMSUM_Vaccines 
from PortfolioProjectDatabase..CovidVaccinations vac
Join PortfolioProjectDatabase..CovidDeaths dea
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
