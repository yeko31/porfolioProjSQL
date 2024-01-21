
--table 1 covidDeaths
--data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject..covidDeaths
ORDER BY 1,2;

--total cases vs total deaths
--likelihood of dying in US coz of covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM portfolioProject..covidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--total cases vs population
--percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as percentPopulationInfected
FROM portfolioProject..covidDeaths
--WHERE location like '%states%'
ORDER BY 1,2;

--higest infection rate compared to population
SELECT location, population, MAX(total_cases) as HigestInfectionCount, Max((total_cases/population))*100 as percentPopulationInfected
FROM portfolioProject..covidDeaths
GROUP BY location, population
ORDER BY percentPopulationInfected DESC;

--highest countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as totalDeathCounts --data type in excel is varchar 
FROM portfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCounts DESC;

-- by continent 
SELECT location, MAX(cast(total_deaths as int)) as totalDeathCounts --data type in excel is varchar 
FROM portfolioProject..covidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCounts DESC;

-- continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as totalDeathCounts --data type in excel is varchar 
FROM portfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCounts DESC;

-- global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage --type new deaths were varchar
FROM portfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--table 2 covidVacs
SELECT * FROM portfolioProject..covidVac
ORDER BY 3,4;

--combining both tables
-- total populations and vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
FROM portfolioProject..covidDeaths dea
JOIN portfolioProject..covidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



-- perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- temp table
DROP TABLE if exists percentPopuVaccinated;
CREATE TABLE percentPopuVaccinated(
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATETIME,
	population NUMERIC,
	newVaccinations NUMERIC,
	rollingPeopleVaccinated NUMERIC

);




