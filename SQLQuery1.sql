use portfoliaproject;
-- loking at total cases vs total deaths
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage,population
from portfoliaproject..coviddeath
order by 1,2

-- looking at total death vs population
select location, date,total_cases,population, (total_cases/population)*100 as case_to_population
from coviddeath
order by 1

-- coutries with highest infection rates
select  location, max(total_cases) as highest_infection_count, (max(total_cases/population))*100 as rate
from coviddeath
group by location
order by 3


--countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcounts
from portfoliaproject..coviddeath
where continent is not null
group by location
order by 2 desc

--with respect to continent

select location as continent ,max(cast(total_deaths as int)) as totaldeathcounts
from portfoliaproject..coviddeath
where continent is null
group by location
order by 2 desc

--global numbers
select date, sum(convert(int,new_cases)), sum(convert(int,new_deaths))
from portfoliaproject..coviddeath
group by date
order  by 1


--use CTE

with popvsvac (continent,location,date,population,new_vaccinations,total_vaccination)
as
-- join the two tables together
(select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as total_vaccination
from portfoliaproject..coviddeath  cd
join portfoliaproject..covidvaccination cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent  is not null
and cd.location like 'india'
--order by 2,3
)
select *,(total_vaccination/population)*100
from popvsvac





-- temp table
drop table if exists #percentpopulationvaccination
create table #percentpopulationvaccination
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccination int,
total_vaccination int,
)
insert into #percentpopulationvaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as total_vaccination
from portfoliaproject..coviddeath  cd
join portfoliaproject..covidvaccination cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent  is not null
and cd.location like 'india'
order by 2,3

select *,(total_vaccination/population)*100
from #percentpopulationvaccination




--create view to store data afor later visulation
create view percentpopulationvaccination as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as total_vaccination
from portfoliaproject..coviddeath  cd
join portfoliaproject..covidvaccination cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent  is not null
--order by 2,3



select*
from percentpopulationvaccination