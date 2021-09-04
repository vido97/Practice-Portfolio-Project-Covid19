/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Portfolio_Project..CovidDeaths
order by 3,4

Select *
From Portfolio_Project..CovidVaccination
order by 3,4

--INFECTED & DEATHS--
-- Select data to use
Select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..CovidDeaths
order by 1,2

-- Total case vs total deaths (Death percentage) 
-- Likelihood of dying if contact Covid

Select location,date,total_cases,total_deaths, Round(((total_deaths/total_cases)*100),2) as  Death_percentage
from Portfolio_Project..CovidDeaths
order by 1,2

-- Data in specific country

Select location,date,total_cases,total_deaths, Round(((total_deaths/total_cases)*100),2) as  Death_percentage
from Portfolio_Project..CovidDeaths
where location ='Vietnam' or location ='Finland'
order by location, Death_percentage DESC

Select location,date,total_cases,total_deaths, Round(((total_deaths/total_cases)*100),2) as  Death_percentage
from Portfolio_Project..CovidDeaths
where location ='Finland' and total_deaths >1000
order by 1,2, 5 DESC

-- Percentage of population has got Covid

Select location,date,population,total_cases,Round(((total_cases/population)*100),2) as PercentInfected_Population
from Portfolio_Project..CovidDeaths
order by location,PercentInfected_Population DESC

--- Country has most infected cases

Select location, population, max(total_cases) as Max_total_cases, 
Round((max((total_cases/population)*100)),2) as PercentInfected_Population
from Portfolio_Project..CovidDeaths
-- Exclude continent from Location
where continent is not NULL
Group by location, population
Order by 3 Desc

--- Country has most death cases
-- total_deaths has wrong data type, to cast (nvarchar25 -> int)

Select location, max(cast(total_deaths as int)) as Max_total_deaths 
from Portfolio_Project..CovidDeaths
where continent is not NULL
Group by location
Order by 2 Desc
 
 --Death cases per continent
Select continent, max(cast(total_deaths as int)) as Max_total_deaths 
from Portfolio_Project..CovidDeaths
where continent is not NULL
Group by continent
Order by 2 Desc

 -- Global figures
 Select sum(new_cases) as New_cases,sum(cast(new_deaths as int)) as New_deaths,sum(total_cases) as Total_cases, sum(cast(total_deaths as int)) as Total_deaths
 from Portfolio_Project..CovidDeaths
 where continent is not null 
 group by date
 order by 1 DESC

 Select sum(total_cases), sum(cast(total_deaths as int)) from CovidDeaths


 --- Global figures of year 2020
 Select sum(new_cases) as New_cases,sum(cast(new_deaths as int)) as New_deaths,sum(total_cases) as Total_cases, sum(cast(total_deaths as int)) as Total_deaths
from Portfolio_Project..CovidDeaths
where continent is not null and year(date)=2020
order by 1 DESC

 --- Global figures today
Select sum(new_cases) as New_cases,sum(cast(new_deaths as int)) as New_deaths,sum(total_cases) as Total_cases, sum(cast(total_deaths as int)) as Total_deaths
from Portfolio_Project..CovidDeaths
where continent is not null and date=(SELECT GETDATE())
order by 1 DESC

 --- Death cases per week?

--VACCINATIONS--
Select dea.location, dea.population, dea.date,vac.total_vaccinations, ((total_vaccinations/population)*100) as PercentVaccinated_Population
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccination vac
on dea.location=vac.location and dea.date=vac.date
where dea.location='Vietnam'
order by dea.date

-- Total Population vs Vaccinations
-- Rolling count people that got vaccinated
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Use CTE or create Temp table to calculate RollingPeopleVaccinated/Population
With cte_RPV (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- to exclude order by 2,3 (cannot use order by in CTE)
)

Select *,(RollingPeopleVaccinated/population)*100 as Rolling_Percentage_vaccinated
from cte_RPV


-- TEMP TABLE
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- to exclude order by 2,3 (cannot use order by in CTE)


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Create view to store data for visualization
Create view 

--average new test done per date vs new death

select * from CovidVaccination

select location,sum(total_cases/population)*100 from CovidDeaths
group by location