

Select *
From [Portfolio project]..covideaths
where continent is not null
order by 3,4




--Select *
--From [Portfolio project]..covidvaccinations
--order by 3,4

--selecting the data to explore
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project]..covideaths
where continent is not null
order by 1,2


--looking at total cases vs total deaths
--likelihood of dying if one got covid relative to the country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPct
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
order by 1,2

--Looking at total cases vs Population
--Percentage of the Population that got covid
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPct
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
order by 1,2

--Looking at coutnries with highest infection rates relative to the population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PctofPopulationInfected
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
Group by location, population
order by PctofPopulationInfected desc

--Looking at countries with highest death count  per population
Select location, max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking Down to continent
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers by date
Select date, sum(new_cases) as SumNewCases, SUM(cast(new_deaths as int)) as SumNewDeaths, (SUM(cast(new_deaths as int))/sum(new_cases)) as DeathPctNew
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
Group by date
order by 1,2

--Total Cases in Globally 
Select  sum(new_cases) as SumNewCases, SUM(cast(new_deaths as int)) as SumNewDeaths, (SUM(cast(new_deaths as int))/sum(new_cases)) as DeathPctNew
From [Portfolio project]..covideaths
--where location like '%Kenya%'
where continent is not null
--Group by date
order by 1,2

--Jin two tables
Select *
From [Portfolio project]..covideaths as cvd
join [Portfolio project]..covidvaccinations as cvv
	on cvd.location = cvv.location
	and cvd.date = cvv. date

--Looking at total population vs vaccination
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, sum(convert(bigint,cvv.new_vaccinations)) OVER (partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
From [Portfolio project]..covideaths cvd
join [Portfolio project]..covidvaccinations  cvv
	on cvd.location = cvv.location
	and cvd.date = cvv. date
where cvd.continent is not null
order by 2,3


--Use CTE

with Pop$Vac (continent, loccation, date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, sum(convert(bigint,cvv.new_vaccinations)) OVER (partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
From [Portfolio project]..covideaths cvd
join [Portfolio project]..covidvaccinations  cvv
	on cvd.location = cvv.location
	and cvd.date = cvv. date
where cvd.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PctRolling
From Pop$Vac

--TEMP TABLE
DROP TABLE if exists #PctPopulationVaccinated
Create Table #PctPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PctPopulationVaccinated
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, sum(convert(bigint,cvv.new_vaccinations)) OVER (partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
From [Portfolio project]..covideaths cvd
join [Portfolio project]..covidvaccinations  cvv
	on cvd.location = cvv.location
	and cvd.date = cvv. date
--where cvd.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PctRolling
From #PctPopulationVaccinated




--Creating view to store data for later viz

create view PctPopulationVaccinated as
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, sum(convert(bigint,cvv.new_vaccinations)) OVER (partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
From [Portfolio project]..covideaths cvd
join [Portfolio project]..covidvaccinations  cvv
	on cvd.location = cvv.location
	and cvd.date = cvv. date
where cvd.continent is not null
--order by 2,3


Select *
From PctPopulationVaccinated