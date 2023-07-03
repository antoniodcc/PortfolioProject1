-- Selecting Data

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths, i.e. Death Percentage
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
order by 1,2

-- Total Cases vs Population, i.e. Cases Percentage
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From Portfolio_Project..CovidDeaths
Where location like '%Italy%'
order by 1,2

-- Countries with the highest rate of infected in relation to population
-- TBL 3
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

--Countries with the highest number of deaths in relation to population
Select location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Group by Location, population
order by DeathPercentage desc

-- World Numbers: total deaths in the world
--TBL 1
Select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Classifica continenti e numero di morti
--  TBL 2
Select location, sum(cast(new_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
where continent is null
and location not in ('world', 'European Union', 'International')
Group by Location
order by TotalDeathCount desc

-- Continents Numbers: Highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- joining two tables
select *
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Total Population vs Total Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- How many Vaccinations in every Country (1)
-- USE CTE (Common Table Expression), in order to use a newly created column. i.e. RollingPeopleVaccinated

with PopVSVac (continent, location, date, population, RollingPeopleVaccinated, new_vaccinations)
 as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100
from PopVSVac

-- How many Vaccinations in every Country (2)
-- In addition to CTE, we can use tempTable (temporary table)

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating a view for Tableau

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
