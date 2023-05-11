select*
from portfolio..CovidDeaths$
WHERE continent is not null
order by 3,4


--select*
--from portfolio..CovidVaccinations$
--order by 3,4

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from portfolio..CovidDeaths$
order by 1,2

-- look at the total cases vs total deaths
--Shows loolihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DethPercentage
from portfolio..CovidDeaths$
WHERE location like '%states'
order by 1,2

-- Looking at total cases vs population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
Group by Location
order by TotalDeathCount desc

--let's break things down by Location
Select location , MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
--Where location like '%states%'
Where continent is  null 
Group by location
order by TotalDeathCount desc

--let's break things down by continent

Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Showing the continent with the highest count death per population

Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


---- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCase, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths$
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
Order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths$ dea
JOIN Portfolio..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac( continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths$ dea
JOIN Portfolio..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT*, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM Portfolio..covidDeaths$ dea
JOIN Portfolio..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT*
FROM PercentPopulationVaccinated