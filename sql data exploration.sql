Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Where continent is not NULL
--Order by 3,4

-- Select data that we are going to be using
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location Like '%states%'
And continent is not NULL
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location Like '%states%'
Order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select location,population ,Max(total_cases) AS HighestInfectionCount, population, Max((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location Like '%states%'
Group by location, population
Order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per population

--Let's Breaking things down by continent

Select continent ,Max(cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
-- Where location Like '%states%'
Where continent is not NULL
Group by continent
Order by TotalDeathCount DESC

--Showing the continent with the highest death count per population 
Select continent ,Max(cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
-- Where location Like '%states%'
Where continent is not NULL
Group by continent
Order by TotalDeathCount DESC

-- Global numbers

Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location Like '%states%'
Where continent is not NULL
--Group by date
Order by 1,2

-- Lookig at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeolpeVaccinated
	  -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
Where dea.continent is not Null
Order by 2,3

-- Use CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	  -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
Where dea.continent is not Null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
Drop Table if exists #PercentagePopulationVaccinated01
Create Table #PercentagePopulationVaccinated01
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated01
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	  -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
Where dea.continent is not Null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentagePopulationVaccinated01

--Creating view to store for later visualizations

Create View PercentagePopulationVaccinated02 as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	  -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
Where dea.continent is not Null
--Order by 2,3
