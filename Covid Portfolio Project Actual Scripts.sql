--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2

--LOOK AT TOTAL CASES VS TOATL DEATHS
--SHOWS LIKELIKHOOD OF DYING IF YOU CONTACT COVID IN YOUR COUNTRY 
Select Location, date, total_cases, total_deaths, 
CASE
WHEN total_cases > 0 then (total_deaths/total_cases) *100
ELSE 0
End as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%sri lanka%'
order by 1,2


Select Location, date, total_cases, total_deaths, 
CASE
WHEN total_cases > 0 then (total_deaths/total_cases) *100
ELSE 0
End as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2


--LOOKING AT TOTAL CASES VS POPULATION 
--Shows percentage of population got covid
Select Location, date, population, total_cases, total_deaths, 
CASE
WHEN total_cases > 0 then (total_cases/population) *100
ELSE 0
End as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2

Select Location, date, population, total_cases, total_deaths, 
CASE
WHEN total_cases > 0 then (total_cases/population) *100
ELSE 0
End as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Sri Lanka%' 
order by 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMAPRED TO POPULATION

Select 
	Location, 
	Population,
	MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
From 
PortfolioProject..CovidDeaths
Group By 
	Location, 
	Population
order by PercentPopulationInfected desc
	

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
--if your getting weird numbers makesure to cast data from nvarchar to an int or float


Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--BREAK DOWN BY CONTINENT, show highest death count per continent
Select location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc



--GLOBAL NUMBERS/GLOBAL DEATH PERCENTAGE


SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) > 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100
        ELSE 0 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
----GROUP BY 
----    date
ORDER BY 
    1,2;


	--LOOKING AT TOTAL POPULATION VS VACCINATIONS

	Select *

	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date

		
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	order by 2,3




	--USE CTE

With popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

)
Select * , (RollingPeopleVaccinated/Population) *100
From popvsvac



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated