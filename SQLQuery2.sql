-- How many deaths and cases were in each country
SELECT location, MAX(total_deaths) as 'Number of deaths', MAX(total_cases) as 'Number of cases'
FROM dbo.CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America')
GROUP BY location
ORDER BY 1

-- How many deaths and cases were on each continent
SELECT location, MAX(total_deaths) as 'Number of deaths', MAX(total_cases) as 'Number of cases'
FROM dbo.CovidDeaths
WHERE location IN ('Africa', 'Asia', 'Australia', 'Europe', 'North America', 'South America')
GROUP BY location
ORDER BY 1

-- What is the probability of death if you got infected
SELECT location, MAX(total_deaths) as 'Number of deaths', MAX(total_cases) as 'Number of cases',(MAX(total_deaths)/MAX(total_cases))*100 as Death_Percentage
FROM dbo.CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America')
GROUP BY location
ORDER BY 1, 4

-- How many deaths and cases were in Czechia
SELECT location, MAX(total_deaths) as 'Number of deaths', MAX(total_cases) as 'Number of cases', (MAX(total_deaths)/MAX(total_cases))*100 as Death_Percentage
FROM dbo.CovidDeaths
WHERE location IN ('Czechia')
GROUP BY location

--Looking at countries with the highest death percentage
SELECT location, MAX(total_deaths) as 'Number of deaths', MAX(total_cases) as 'Number of cases',(MAX(total_deaths)/MAX(total_cases))*100 as Death_Percentage
FROM dbo.CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America')
GROUP BY location
ORDER BY 4 DESC

--Looking at countries with the highest infection rate compared to population
SELECT location, MAX(total_cases) as 'Highest Infection Count', MAX(total_cases/population)*100 as Ratio
FROM dbo.CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America')
GROUP BY location
ORDER BY 3 DESC, 2 DESC

--Showing countries with the Highest Death Count per population
SELECT location, MAX(total_deaths/population)*100 as 'Death Count per Population'
FROM dbo.CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America')
GROUP BY location
ORDER BY 2 DESC

--On which date we got the most cases
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as 'Death Rate'
FROM dbo.CovidDeaths
WHERE new_deaths <> 0
GROUP BY date
ORDER BY 2,4 DESC

--How many people got vaccinated
SELECT cd.location, MAX(cd.population) as population, MAX(cv.total_vaccinations) as vaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America', 'International')
GROUP BY cd.location
ORDER BY 3 DESC

--Whats the percentage of vaccinated people
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated
FROM dbo.CovidDeaths cd
JOIN dbo.CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America', 'International')
ORDER BY 2 DESC

--CTE
WITH Popvsvac (Location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated
FROM dbo.CovidDeaths cd
JOIN dbo.CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America', 'International')
)

SELECT*, (Rolling_People_Vaccinated/population)*100
FROM Popvsvac

--Temp table
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated(
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
Rolling_people_vaccinated nvarchar(255)
)

INSERT INTO PercentPopulationVaccinated
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated
FROM dbo.CovidDeaths cd
JOIN dbo.CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.location NOT IN ('Africa', 'Asia', 'Australia', 'Europe', 'European Union', 'World', 'North America', 'South America', 'International')
ORDER BY 2 DESC

SELECT*, (Rolling_People_Vaccinated/population)*100
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (Partition by dea.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths cd
Join dbo.CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null 

--How many patients are in ICU
SELECT MAX(icu_patients)
FROM dbo.CovidDeaths
GROUP BY location

--How many infected people were hospitalised
SELECT location, (hosp_patients/MAX(total_cases))*100 as 'Percentage of hospitalised patients'
FROM dbo.CovidDeaths
WHERE location IN ('Africa', 'Asia', 'Australia', 'Europe', 'North America', 'South America')
GROUP BY location
ORDER BY 1

