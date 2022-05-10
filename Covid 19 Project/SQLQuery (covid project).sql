-- Selecting all data from both tables to check their validity
SELECT * FROM Covid_Portfolio_Project..CovidDeaths;
SELECT * FROM Covid_Portfolio_Project..CovidVaccinations;

-- Selecting data to be used for querying in the Covid Deaths table
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
Order by 1,2;

-- How many total deaths vs total cases did we have in Nigeria? (showing the likelihood of dying from covid)
SELECT location, date, total_cases, total_deaths, (ROUND((total_deaths/total_cases)*100,2)) AS Fatality_Rate
FROM Covid_Portfolio_Project..CovidDeaths
WHERE location = 'Nigeria'
Order by 1,2;

--How many cases did we have have per population in Africa? (showing the percentage of population that had covid)
SELECT continent, location, date, total_cases, population, (ROUND((total_cases/population)*100,2)) AS Percentage_case_per_population
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent = 'Africa'
Order by 1,2;

-- Which countries had the highest infection rate (%) compared to population
SELECT location, MAX(total_cases) AS Infection_Count, population, (ROUND(MAX((total_cases/population))*100,2)) AS Infection_rate
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infection_rate DESC;

-- Which countries had the highest death rate (%) compared to population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Death_Count, population, (ROUND(MAX((total_deaths/population))*100,2)) AS Death_rate
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Death_rate DESC;

--Which continent had the highest death count and death rate?
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Death_Count
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;

-- ANALYSING GLOBAL NUMBERS

--Number of new covid cases and death rates in the world on a daily basis 
SELECT date, SUM(new_cases) AS Global_cases, SUM(CAST(new_deaths AS INT)) AS Global_Deaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS Global_Death_rate
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total cases, deaths and death rate of Covid Globally
SELECT SUM(new_cases) AS Global_cases, SUM(CAST(new_deaths AS INT)) AS Global_Deaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS Global_Death_rate
	FROM Covid_Portfolio_Project..CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 1,2;

--Selecting Data to be used from the Covid Vaccinations Table

-- Joining the Covid Deaths and Covid vaccinations together
SELECT *
	FROM Covid_Portfolio_Project..CovidDeaths AS Deaths
	JOIN Covid_Portfolio_Project..CovidVaccinations AS Vaccinations
	ON Deaths.continent=Vaccinations.continent
	AND Deaths.date=Vaccinations.date;

-- How many people in the world have already been vaccinated?
SELECT  Deaths.date, Deaths.total_cases, Vaccinations.new_vaccinations
	FROM Covid_Portfolio_Project..CovidDeaths AS Deaths
	JOIN Covid_Portfolio_Project..CovidVaccinations AS Vaccinations
	ON Deaths.continent=Vaccinations.continent
	WHERE Deaths.continent IS NOT NULL
	AND Deaths.date=Vaccinations.date
	ORDER BY 2,3;

-- Updated number of vaccinated people every day
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,SUM(CONVERT(INT, Vaccinations.new_vaccinations)) 
	OVER (PARTITION BY Deaths.location ORDER BY Deaths.location) AS daily_total_vaccinated
	FROM Covid_Portfolio_Project..CovidDeaths AS Deaths
	JOIN Covid_Portfolio_Project..CovidVaccinations AS Vaccinations
	ON Deaths.continent=Vaccinations.continent
	WHERE Deaths.continent IS NOT NULL
	AND Deaths.date=Vaccinations.date
	ORDER BY 2,3;


-- Using CTE
WITH Population_Vs_Vaccinations (continent, location, date, population, new_vaccinations, Daily_people_vaccinated) AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, SUM(CONVERT(INT, Vaccinations.new_vaccinations)) 
	OVER (PARTITION BY Deaths.location, Deaths.date ORDER BY Deaths.location) AS Daily_people_vaccinated
	FROM Covid_Portfolio_Project..CovidDeaths AS Deaths
	JOIN Covid_Portfolio_Project..CovidVaccinations AS Vaccinations
	ON Deaths.continent=Vaccinations.continent
	WHERE Deaths.continent IS NOT NULL
)
SELECT *, ROUND((Daily_people_vaccinated/population)*100,2)
FROM Population_Vs_Vaccinations

