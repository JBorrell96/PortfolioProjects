--SELECT *
--FROM PortfolioeProject.dbo.CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--SELECT *
--FROM PortfolioeProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioeProject.dbo.CovidDeaths
--ORDER BY 1, 2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, cast(total_cases as int), cast(total_deaths as int), (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE total_cases IS NOT NULL
	AND continent IS NOT NULL
	--AND location like '%states%'
ORDER BY 1, 2

-- Looking at TotalCases vs Population

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
GROUP BY Location, Population
ORDER BY 4 DESC

-- Showing Countries with the highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
GROUP BY date
ORDER BY 1, 2

--GLOBAL NUMBER AGGREGATED

SELECT SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%states%'
--GROUP BY date
ORDER BY 1, 2

--GLOBAL DEATH RATE
SELECT DISTINCT location, SUM(population) as total_population, SUM(cast(new_deaths as int)) as total_deaths, SUM(population)/SUM(cast(new_deaths as int))*100 as TotalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
	--AND location like '%states%'
GROUP BY location
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY 
dea.Location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE subquery

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY 
dea.Location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingVaccinationCount/population) *100
FROM PopvsVac
ORDER BY 2, 3


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY 
dea.Location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingVaccinationCount/population) *100
FROM #PercentPopulationVaccinated
ORDER BY 2, 3

--Creaing view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY 
dea.Location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated