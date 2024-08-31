Select * 
From PortifolioProject.dbo.CovidDeath
Where continent is not null
order by 3,4

--SELECT *
--From PortifolioProject.dbo.CovidVACS$
--Where continent is not null
--order by 3,4

Select Location , date, total_cases, new_cases, total_deaths, population
From PortifolioProject.dbo.CovidDeath
Where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelyhood of dying if you recieved covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percent
From PortifolioProject.dbo.CovidDeath
Where Location like '%United States%'
and continent is not null
Order by 1,2

-- Looking at total cases vs population
-- Shows percentae of population has covid 
Select Location, date, total_cases, population, (total_cases/population) * 100 as Population_Covid_Rate
From PortifolioProject.dbo.CovidDeath
--Where location like '%United States%'
order by 1,2

-- Looking at countries with highest infection rate
Select Location, MAX(total_cases) as Highest_Infection_Count , population, MAX((total_cases/population)) * 100 as Highest_Infection_Rate
From PortifolioProject.dbo.CovidDeath
--Where location like '%United States%'
Group by Location, population
order by Highest_Infection_Rate desc

Select Location, Population,date,Max(total_cases) as Highest_Infection_Count, MAX((total_cases/population)) * 100 as Percent_Population_Infected
From PortifolioProject.dbo.CovidDeath
--Where location like '%states%'
Group by Location, Population,date 
order by Percent_Population_Infected desc

-- Showing countries wit the highest death count per population
Select Location, Max(cast (total_deaths as int)) as Total_Death_Count
From PortifolioProject.dbo.CovidDeath
--Where location like '%United States%'
Where continent is not null
Group by Location, population
order by Total_Death_Count desc

--Lets break things down by continent
-- Showing continents with the highest death count
Select continent, Max(cast (total_deaths as int)) as Total_Death_Count
From PortifolioProject.dbo.CovidDeath
--Where location like '%United States%'
Where continent is not null
Group by continent
order by Total_Death_Count desc

-- Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases) * 100 as Death_Percetage--, total_deaths, (total_deaths/total_cases) * 100 as Death_Percent
From PortifolioProject.dbo.CovidDeath
--Where Location like '%United States%'
where continent is not null
--group by date
Order by 1,2

Select Location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortifolioProject.dbo.CovidDeath
Where Continent is null
and location not in ('World','European Union','International')
Group by location
order by TotalDeathCount desc


--USE CTE
with PopVsVac(Continent, Location, Date, Population, New_Vaccinations,rolling_people_vaccinated)
as

(
-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as rolling_people_vaccinated--, (rolling_people_vaccinated/population)* 100
From PortifolioProject.dbo.CovidDeath dea
Join PortifolioProject.dbo.CovidVACS$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (Rolling_People_Vaccinated/population)*100
From PopVsVac


-- Temp Table
Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as rolling_people_vaccinated--, (rolling_people_vaccinated/population)* 100
From PortifolioProject.dbo.CovidDeath dea
Join PortifolioProject.dbo.CovidVACS$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (Rolling_People_Vaccinated/population)*100
From #Percent_Population_Vaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as rolling_people_vaccinated--, (rolling_people_vaccinated/population)* 100
From PortifolioProject.dbo.CovidDeath dea
Join PortifolioProject.dbo.CovidVACS$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

