# Introduction
Dieses Projekt konzentriert sich auf die kritische Phase der Datenbereinigung und -aufbereitung sowie auf die Durchführung von Datenabfragen, um wertvolle Erkenntnisse aus unseren Datensätzen zu gewinnen. 

🔍 SQL queries? Findest du hier:[data queries](/data_queries/)

🔍 Data Cleaning? Findest du hier:[data cleaning](/data_cleaning/)


# Backround

## Nashville Housing Datensatz
Ein zentraler Aspekt dieses Projekts war die Bereinigung des Nashville_Housing-Datensatzes. Durch sorgfältige Aufbereitung und Bereinigung der Daten habe ich sicherstellen wollen, dass sie leichter analysiert und interpretiert werden können. Dieser Schritt war entscheidend, um die Qualität der Daten zu verbessern und eine solide Grundlage für unsere Analyse zu schaffen.


## COVID-Datensatz und SQL-Analysen
Darüber hinaus habe ich umfangreiche SQL-Abfragen auf einem COVID-Datensatz durchgeführt, um Einblicke in die Auswirkungen der Pandemie zu gewinnen. Die Nutzung von SQL ermöglichte es mir, komplexe Abfragen durchzuführen und spezifische Informationen aus dem Datensatz zu extrahieren. Diese Analysen waren von entscheidender Bedeutung, um Trends zu identifizieren, Muster zu erkennen und fundierte Entscheidungen zu treffen.

# Tools I Used
Für meine intensive Untersuchung des Datenanalysten-Arbeitsmarktes habe ich folgende Werkzeuge genutzt:

- SQL: Das Rückgrat meiner Analyse, das es mir ermöglicht, die Datenbank abzufragen und wichtige Erkenntnisse zu gewinnen.
- SSMS: Das ausgewählte Datenbankmanagementsystem, ideal für die Verarbeitung der Daten.
- Visual Studio Code: Mein Favorit für das Datenbankmanagement und die Ausführung von SQL-Abfragen.
- Git & GitHub: Unverzichtbar für die Versionskontrolle und das Teilen meiner SQL-Skripte und Analysen, um Zusammenarbeit und Projektverfolgung sicherzustellen.

# The Analyis 
## Countries with Highest Infection Rate compared to Population

```sql
SELECT
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    max(total_cases/population)*100 as higest_infections_rate
FROM
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE
     continent is not NULL
GROUP BY
    location,population
order by population desc;
```

![](/assets/Screenshot%202024-04-05%20124304.png)

Die Abfrage identifiziert die am stärksten betroffenen Standorte basierend auf ihren Bevölkerungszahlen und COVID-19-Fallzahlen. Durch die Berechnung der höchsten Infektionsrate können Gebiete mit besonders hohem Risiko ermittelt werden.


## Countries with Highest Death Count per Population

```sql
SELECT
    location,
    population,
    cast( MAX(total_deaths) as int) as HighestDeathCount,
    max(cast(total_deaths as int)/population)*100 as higest_death_rate
FROM
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE
    continent is not null 
GROUP BY
    location,population
order by higest_death_rate desc;
```
![](/assets/Screenshot%202024-04-05%20124836.png)

Die Abfrage identifiziert die Standorte mit den höchsten COVID-19-Todeszahlen und berechnet die entsprechenden Sterberaten pro Bevölkerung. Durch die Umwandlung der Todeszahlen in ganze Zahlen werden präzisere Vergleiche ermöglicht. Die Sortierung nach der höchsten Sterberate bietet Einblicke in die Regionen mit dem größten Risiko für schwere Auswirkungen der Pandemie. Diese Analyse liefert wichtige Informationen für die Einschätzung des Gesundheitsrisikos in verschiedenen Gebieten. Sie kann dazu beitragen, gezielte Maßnahmen zur Reduzierung der Sterblichkeit und zur Verbesserung der Gesundheitsversorgung zu planen

## Getting Global Numbers
```sql
SELECT 
    SUM(new_cases) as total_cases, -- count of all infektet person globaly
    SUM(cast(new_deaths as int)) as total_deaths,
    (SUM(cast(new_deaths as int)) / SUM(new_cases)) *100 as globy_death_percentage
FROM 
    SQL_Portfolio_Projekt..CovidDeaths$
WHERE 
    continent is not NULL

```
![](/assets/Screenshot%202024-04-05%20125353.png)

Die Abfrage berechnet aggregierte Statistiken zu COVID-19-Fällen und Todesfällen weltweit. Sie zeigt die Gesamtzahl der gemeldeten Infektions- und Todesfälle auf globaler Ebene. Durch die Berechnung des Prozentsatzes der Todesfälle im Verhältnis zu den Gesamtinfektionen wird ein Überblick über die Mortalitätsrate der Krankheit geboten. Diese Analyse liefert eine wichtige Kennzahl zur Einschätzung der Schwere und des Ausmaßes der COVID-19-Pandemie auf globaler Ebene.

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

## Total Population vs Vaccinations

```sql
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
```

Die Abfrage kombiniert Daten zu COVID-19-Todesfällen und Impfungen, um einen Überblick über den Fortschritt der Impfkampagne in verschiedenen Standorten zu geben. Sie verbindet die Todesfälle und Impfdaten basierend auf Ort und Datum. Durch die Berechnung der kumulierten Impfungen über die Zeit und den Standort wird der Gesamtfortschritt der Impfungen pro Standort dargestellt. Die Verwendung eines CTEs ermöglicht die Berechnung des prozentualen Anteils der geimpften Bevölkerung für jede Standort- und Zeitkombination. Diese Analyse bietet Einblicke in die Beziehung zwischen Impffortschritt und Bevölkerungszahlen und unterstützt die Bewertung der Effektivität von Impfkampagnen in verschiedenen Regionen. Sie kann dazu beitragen, Strategien zur Verbesserung der Impfabdeckung und zur Eindämmung der COVID-19-Verbreitung zu entwickeln.


# What I Learned

Während dieser spannenden Reise habe ich meine Fähigkeiten in der Datenbereinigung und -abfrage erheblich erweitert:

🧩 Effiziente Datenbereinigung: Meisterte die Kunst der Datenbereinigung, indem ich komplexe Transformationen durchführte und Daten von unerwünschten Artefakten befreite, um eine saubere und zuverlässige Datenbasis zu schaffen.

📊 Präzise Datenabfragen: Verwendete fortschrittliche Abfragetechniken, um gezielte Einblicke in die Daten zu gewinnen. Durch die Nutzung von GROUP BY und aggregierten Funktionen wie COUNT() und AVG() konnte ich Daten effektiv aggregieren und zusammenfassen.

💡 Analytische Raffinesse: Transformierte reale Fragestellungen in aussagekräftige SQL-Abfragen, um wertvolle Erkenntnisse zu gewinnen und strategische Entscheidungen zu unterstützen.


# Conclusions
Aus der Analyse ergaben sich mehrere allgemeine Erkenntnisse schau [hier](/data_queries/) und [hier](/data_cleaning/)
