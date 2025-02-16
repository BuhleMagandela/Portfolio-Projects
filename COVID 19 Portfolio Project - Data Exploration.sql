
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihhood of dying if you contract covid in your country 

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%South Africa%'
 and continent is not null
order by 1,2


--Looking at Total cases vs Population
--Shows what percentage of population got covid

Select Location, Date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%South Africa%'
Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%South Africa%'
Group by Location, population
Where continent is not null
order by PercentPopulationInfected desc

--Showing Countries with  Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%South Africa%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAK THINNGS DOWN BY CONTINENT


-- Showing Continents with the Highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%South Africa%'
Where continent is null
Group by Location
order by TotalDeathCount desc


-- GLOBLAL NUMBERS

Select Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%South Africa%'
 Where continent is not null
 Group by Date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%South Africa%'
 Where continent is not null
 --Group by Date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac





--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric ,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--TEMP TABLE for sql  server 2016 and later versions

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;



-- CREATING VIEW FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select * from 
PercentPopulationVaccinated
