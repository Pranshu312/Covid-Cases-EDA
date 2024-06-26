select * 
from ..CovidDeaths


select location,date,total_cases,new_cases,total_deaths,population
from ..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total deaths

select location,date,total_cases,total_deaths,
(CONVERT(float,total_deaths)/nullif(CONVERT(float,total_cases),0)) * 100 as DeathPercentage
from ..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Population

select location,date,total_cases,population,
(CONVERT(float,total_cases)/nullif(CONVERT(float,population),0)) * 100 as CasesPercentage
from ..CovidDeaths
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as Highest_Infection_Count,
max((CONVERT(float,total_cases)/nullif(CONVERT(float,population),0))) * 100 as Max_Cases_Percentage
from ..CovidDeaths
where continent is not null
group by location,population
order by 4 desc

--Countries with Highest Death Count per Population

select location,max(CONVERT(int,total_deaths)) as Total_Death_Count
from ..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc;

-- Grouping by Continent
select continent,max(CONVERT(int,total_deaths)) as Total_Death_Count
from ..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc;

-- Continents with Highest Death Count per Population

select continent,max(CONVERT(int,total_deaths)/population) * 100 as Total_Death_Count
from ..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc;

-- GLOBAL NUMBERS

select date,sum(new_cases) as Total_cases,sum(new_deaths) as Total_deaths,
case 
    when sum(new_cases) != 0 then (sum(new_deaths)/sum(new_cases))*100 
	else 0
end as DeathPercentage
from ..CovidDeaths
where continent is not null
group by date
order by 1,2;


-- Total Population vs Vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as total_vaccinations
from ..CovidVaccinations as vac
join ..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

with PopvsVac as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as total_vaccinations
from ..CovidVaccinations as vac
join ..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null)
select *,(total_vaccinations/population)*100
from PopvsVac

