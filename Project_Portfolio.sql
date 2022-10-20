-- Selezionare i dati che useremo

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

-- Casi totali vs Morti totali, cioè la percentuale di morti tra le persone che hanno contratto il covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
order by 1,2

-- Casi Totali vs Popolazione, cioè la percentuale di persone che ha il covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From Portfolio_Project..CovidDeaths
Where location like '%Italy%'
order by 1,2

-- Stati con il tasso di infetti più alto rispetto al numero di abitanti
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasesPercentage
From Portfolio_Project..CovidDeaths
Group by Location, population
order by CasesPercentage desc

--Stati con il più alto numero di morti in riferimento alla popolazione
Select location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Group by Location, population
order by DeathPercentage desc
--la funzione CAST serve a convertire un tipo di file in un altro tipo di file.

-- Numeri dal mondo
Select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- uniamo le due tabelle
select *
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- la somma di quante vaccinazioni sono state fatte ogni giorno
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- quante vaccinazioni siamo in ogni parte del mondo
-- bisogna usare una CTE (Common Table Expression), per riutilizzare la colonna appena creata. Nel nostro caso RollingPeopleVaccinated

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
from popvsvac

-- quante vaccinazioni siamo in ogni parte del mondo
-- per fare la stessa cosa, oltre alla CTE si può usare una tempTable (temporary table)

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

-- Creiamo una View per usare dopo i dati
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
