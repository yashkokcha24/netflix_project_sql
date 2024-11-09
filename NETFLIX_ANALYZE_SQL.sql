-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type VARCHAR(10),	
	title	VARCHAR(150),
	director  VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description  VARCHAR(250)

);

select * from netflix

copy netflix FROM 'G:\postgre sql\netflix_titles.csv'
delimiter ','
CSV HEADER;



select 
	count(*) as total_content
from netflix;


SELECT 
	DISTINCT type
FROM netflix;


-- 15 Business Problems 

-- 1. Count the number of movies vs TV Shows
SELECT
	type,
	count(*) as total_content
FROM netflix
GROUP BY type


-- 2. Find the most common rating for movies and TV shows
SELECT
	type,
	rating
FROM

(
SELECT
	type,
	rating,
	count(*),
	RANK() OVER(PARTITION BY type ORDER BY count(*)DESC) as ranking
FROM netflix
GROUP BY 1,2
)as t1
WHERE
	ranking= 1



-- 3. List all movies released in a specific year(e.g 2020)

-- Filter 2020
-- movies
select * from netflix
where 
	type= 'Movie'
	AND
	release_year= 2020;



-- 4. Find the top 5 countries with the most content on netflix
select 
	UNNEST(STRING_TO_ARRAY(country,','))AS new_country,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5


-- 5. Identify the largest movie
select * from netflix
where 
	type= 'Movie'
	AND
	duration= (select MAX(duration) from netflix)



-- 6. Find content added in the last 5 years
select * from netflix
where
	TO_DATE(date_added,'Month DD, YYYY')>= CURRENT_DATE - INTERVAL '5 years'
	


--7. Find all the movies/TV showa by director 'Rajiv Chilaka'
select 
	type,
	director
from netflix
where director ILIKE '%Rajiv Chilaka%'




--8. List all TV shows with more than 5 season
select 
	* 
from netflix
where 
	type= 'TV Show' and
	SPLIT_PART(duration,' ',1)::numeric >5 




--9. Count the number of content items in each genre
select
	unnest(string_to_array(listed_in,',')) as genre,
	count(show_id) as total_content
from netflix
group by 1;




--10. Find each year and the average number of content release by india on netflix return top 5 year with highest abg content release.
select 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))as year,
	count(*) as yearly_report,
	ROUND(
	count(*)::numeric/(select count(*) from netflix where country= 'India')*100 )
	as avg_content_per_year
from netflix
where country= 'India'
group by 1



--11. List all movies that are documentaries
select * from netflix
where listed_in ILIKE '%documentaries%';



--12. Find all the content without a director
select * from netflix
where 
	director is NULL;



--13. Find how many movies actor 'Salman khan' appeared in last 10 years.
select * from netflix
where
	casts ILIKE '%Salman Khan%'
	and
	release_year > Extract(year from current_date)-10




--14. Find the top 10 actors who have appeared in the highest number of movies producted in India.
select 
-- show_id,
-- casts,
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
count(*) as total_content
from netflix
where country ILIKE '%india%'
group by 1
order by 2 DESC
limit 10




-- 15. Categories the content based on the presence of the keywords 'KILL' and 'VIOLENCE' in the description field. Label content containing these 
-- keywords as 'Bad' and all other content as 'Good' count how many itmes fall into each category.
with new_table
as
(
select 
*,
	case 
	when description ILIKE '%kills%' or
		 description ILIKE '%violence%' then 'Bad_content'
		 else 'Good content'
	end category
from netflix
)
select 
	category,
	count(*) as total_content
from new_table
group by 1