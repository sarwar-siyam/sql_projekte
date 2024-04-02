

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- The Main Columns that I work with a

SELECT 
    [location], 
    [date],
    new_cases,
    total_cases,
    total_deaths,
    population
FROM 
    SQL_Portfolio_Projekt..CovidDeaths$;



-- Shows likelihood of dying if you contract covid in your country
-- Total Cases vs Total Deaths

SELECT 
    [location],
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases )*100 as prozentage
FROM
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE 
    [location] like 'Germany';

/*
    Hier erkennen wir das in Deutschland bis zum 28.04.2021 insgesammt 3366827 mit dem Corana Virsu infiziert waren.
    Gestorben sind 82588, was einem Prozensatz von 2,45% entspricht.

*/

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
    [location],
    date,
    population,
    total_cases,
    (total_cases/population)*100 as infektion_rate
FROM 
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE 
    [location] like 'Germany';

/*
    Hier erkennen wir das am 28.04.2021 die Infektionsrate in Deutschland bei 4% lad.

*/

-- Countries with Highest Infection Rate compared to Population


SELECT
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    max(total_cases/population)*100 as higest_infections_rate
FROM
    SQL_Portfolio_Projekt..CovidDeaths$
-- WHERE [location] like 'germany'
GROUP BY
    location,population
order by higest_infections_rate desc;



-- Countries with Highest Death Count per Population

SELECT
    location,
    population,
   cast( MAX(total_deaths) as int) as HighestDeathCount,
    max(cast(total_deaths as int)/population)*100 as higest_infections_rate
FROM
    SQL_Portfolio_Projekt..CovidDeaths$
--WHERE [location] like 'germany'
GROUP BY
    location,population
order by higest_infections_rate desc;


-- Showing contintents with the highest death count per population

SELECT
    continent,
    max(cast(total_deaths as int)) as HighestDeathCount,
    max(cast(total_deaths as int)/population)*100 as higest_infections_rate
FROM
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE 
    continent is not null
GROUP BY
    continent
order by higest_infections_rate desc;


-- Getting the global numbers 


SELECT 
    SUM(new_cases) as total_cases, -- count of all infektet person globaly
    SUM(cast(new_deaths as int)) as total_deaths,
    (SUM(cast(new_deaths as int)) / SUM(new_cases)) *100 as globy_death_percentage
FROM 
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE 
    continent is not NULL



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
    CovidDeaths$.date,
    CovidDeaths$.continent,
    CovidDeaths$.[location],
    CovidDeaths$.population,
    sum(cast(CovidVaccinations$.new_vaccinations as int)) OVER (PARTITION BY CovidDeaths$.[location] ORDER BY CovidDeaths$.[location] ) as new_vaccinations_over_location
    --(new_vaccinations_over_location/CovidDeaths$.population)*100 -- Damit das Abgefragt werden kann muss ein CTE erstellt werden
FROM 
    SQL_Portfolio_Projekt..CovidDeaths$ JOIN SQL_Portfolio_Projekt..CovidVaccinations$
    ON CovidDeaths$.[date] = CovidVaccinations$.[date]
    and CovidDeaths$.[location]= CovidVaccinations$.[location]
WHERE
    CovidDeaths$.continent is not NULL;


-- Erstellung eines CTEs zur Unterstützung der obigen Abfrage 
-- da new_vaccinations_over_location eine Berechnung  ist und nicht in der selben abfrage genutzt werden kann


With PERCENTAGE_VacvsPop (date,continent,location,population,new_vaccinations,new_vaccinations_over_location)
as
(
Select 
    CovidDeaths$.continent, 
    CovidDeaths$.location, 
    CovidDeaths$.date, 
    CovidDeaths$.population, 
    CovidVaccinations$.new_vaccinations,
    SUM(CONVERT(int,CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.Location Order by CovidDeaths$.location, CovidDeaths$.Date) as new_vaccinations_over_location

From 
    CovidDeaths$
Join CovidVaccinations$
	ON CovidDeaths$.location = CovidVaccinations$.location
	AND CovidDeaths$.date = CovidVaccinations$.date
WHERE
    CovidDeaths$.continent is not null )

SELECT * ,( new_vaccinations_over_location/population)* 100 FROM PERCENTAGE_VacvsPop;


