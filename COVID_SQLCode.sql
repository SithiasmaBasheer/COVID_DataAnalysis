select * from coviddeaths 
where continent is not null 
order by 3,4;

/*
select * from covidvaccinations order by 3,4;
*/
 
/* select the data we are going to be using */

select location,date,total_cases,new_cases,total_deaths,population  
from coviddeaths order by 1,2;

/* Looking at Total Cases vs Total Deaths 
 Shows likelihood of dying if you contract covid in your country*/

select location,date,total_cases ,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage 
from coviddeaths 
where location like 'Netherlands' order by 1,2 ;

/* looking at total cases vs population
   Shows what percentage of population got covid */

select location,date,population,total_cases,(total_cases/population) *100 as PercentPopulationInfected 
from coviddeaths 
where location like 'Netherlands' order by 1,2 ;

/*looking at countries with Highest Infection Rate compared to Population*/

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)) *100 as PercentPopulationInfected 
from coviddeaths 
group by location,population 
order by PercentPopulationInfected desc;

/* Showing the countries with highest death count per location */

select location,population, max(total_deaths ) as TotalDeathCount 
from coviddeaths 
where continent is not null 
group by location,population 
order by TotalDeathCount desc;

/*Showing the continents with the highest death count per population*/

/* Let's break things down by continent*/

select continent  , max(total_deaths ) as TotalDeathCount 
from coviddeaths 
where continent is not null
group by continent  
order by TotalDeathCount desc;

/*
Global Numbers
*/
select date,sum(new_cases) as total_cases,sum(new_deaths ) as total_deaths,sum(new_deaths )/sum(new_cases) *100 as DeathPercentage 
from coviddeaths 
where continent is not null 
group by date
order by 1,2 ;



select sum(new_cases) as total_cases,sum(new_deaths ) as total_deaths,sum(new_deaths )/sum(new_cases) *100 as DeathPercentage 
from coviddeaths 
where continent is not null 
/*group by date*/
order by 1,2 ;



select * from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date;

/*
Looking at Total Population vs Vaccinations
*/

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,sum(vac.new_vaccinations) over
(PARTITION by dea.location order by dea.date,dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

/*Use CTE*/

With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)

as

(select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,sum(vac.new_vaccinations) over
(PARTITION by dea.location order by dea.date,dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
/*
order by 2,3
*/
)
select *,(RollingPeopleVaccinated/Population)*100 
from PopvsVac

/*Temp Table*/

/*
Drop table if exists PercentPopulationVaccinated
*/

create temporary table  PercentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population FLOAT,
New_Vaccinations FLOAT,
RollingPeopleVaccinated FLOAT);

Insert into PercentPopulationVaccinated (Continent,
Location,
Date ,
Population ,
New_Vaccinations ,
RollingPeopleVaccinated)
select dea.continent,dea.location,dea.date,dea.population, cast(vac.new_vaccinations as float) ,sum(vac.new_vaccinations) over
(PARTITION by dea.location order by dea.date,dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null;

select *,(RollingPeopleVaccinated/Population)*100 
from PercentPopulationVaccinated;

/*Creating view to store data for future visualizations*/

drop view if exists PercentPopulationVaccinated
Create view  PercentPopulationVaccinated
as
select dea.continent,dea.location,dea.date,dea.population, cast(vac.new_vaccinations as float) ,sum(vac.new_vaccinations) over
(PARTITION by dea.location order by dea.date,dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null;

select * from PercentPopulationVaccinated;

create view T
as
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)) *100 as PercentPopulationInfected 
from coviddeaths 
group by location,population 
order by PercentPopulationInfected desc;


