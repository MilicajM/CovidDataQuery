SELECT * 
FROM ['cDeaths']
WHERE continent is not null
order by 1,2


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ['cDeaths']
order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, CAST (total_deaths AS FLOAT)/CAST (total_cases AS float)* 100 as DeathPercentage
FROM ['cDeaths']
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (CAST (total_cases AS INT)/population)* 100 as InfectedPercentage
FROM ['cDeaths']
WHERE location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(CAST(total_cases AS INT)) as HighestInfectionCount, MAX((CAST (total_cases AS INT)/population))*100 as InfectedPercentage
FROM ['cDeaths']
Group by location, population
order by InfectedPercentage desc

-- This is showing Countries with Highest Death count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM ['cDeaths']
WHERE continent is not null
Group by location
order by TotalDeathCount desc

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM ['cDeaths']
WHERE continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM ['cDeaths']
WHERE continent is not null
Group by continent
order by TotalDeathCount desc




-- Global Numbers

SELECT  date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as NewDeathPercentage
FROM ['cDeaths']
WHERE continent is not null and new_cases != 0
Group by date
order by 1,2

-- Find total death percentage all time

SELECT SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as TotalDeathPercentageAllTime
FROM ['cDeaths']
WHERE continent is not null and new_cases != 0
order by 1,2


-- Take a look at the vaccinations table
SELECT *
FROM cVaccinations

-- Create join between both tables

SELECT *
FROM ['cDeaths'] dea
JOIN cVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Total Population v Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ['cDeaths'] dea
JOIN cVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- Create a rolling count on vaccinations using partition by
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationCounter
FROM ['cDeaths'] dea
JOIN cVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- use a CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, VaccinationCounter)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationCounter
FROM ['cDeaths'] dea
JOIN cVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (VaccinationCounter/population)*100
FROM PopvsVac

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationCounter numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationCounter
FROM ['cDeaths'] dea
JOIN cVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (VaccinationCounter/population)*100 as PercentVaccinatedCounter
FROM #PercentPopulationVaccinated



-- Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationCounter
FROM ['cDeaths'] dea
JOIN cVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- testing view

SELECT *
FROM PercentPopulationVaccinated


