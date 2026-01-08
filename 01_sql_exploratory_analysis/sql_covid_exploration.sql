-- 1) Basic exploration

Select *
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
order by 1,2

--2 looking at Total Cases vs Total Deaths 
Select Location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths 
where location like '%states%'
and continent IS NOT NULL
order by 1,2

--3 Looking at total cases vs the population
--shows what percentage

Select Location, date, Population,total_cases, (Total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
--where location like '%states%'
order by 1,2


--4 Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HightestIfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected	desc


--5 Showing Countries with Highest Death Count per Population 
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%states%'
WHERE continent IS NOT NULL
Group by location
order by TotalDeathCount desc



--6 DOING IT BY CONTINENTS
--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%states%'
WHERE continent IS not NULL
Group by continent
order by TotalDeathCount desc


--7 GLOBAL NUMBERS

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths 
--where location like '%states%'
WHERE continent IS NOT NULL
--group by date
order by 1,2


-- 8 Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent	is not null
Order by 2,3


---9 Use CTE
with  PopvsVac (Continent, Location, Date, Population , New_Vaccinations , RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent	is not null
--Order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From popvsVac



--10 TEMP TABLE

DROP Table if exists  #PercentPopulationVaccinated

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent	is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--11 Creating view to store data	for later visualizations 

USE PortfolioProject;
GO

IF OBJECT_ID('dbo.PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW dbo.PercentPopulationVaccinated;
GO

CREATE VIEW dbo.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER
         (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
GO

Select *
From PercentPopulationVaccinated
