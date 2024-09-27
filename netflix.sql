-- solving 15 business problems using sql
select * from netflix
--1.Counting the number of movies and TV shows

select type, count(*) as total_content
from netflix
group by type

-- movie = 6131
-- TV Show = 2676

-- find the most common rating for movies and for tv shows
select type,rating
	from(
select type, 
	rating, 
	count(*),
	RANK() OVER(partition by type order by count(*) desc) as ranking
from netflix
group by 1, 2
order by 1, 3 desc) as x
where ranking = 1

-- list all the movies released in a specific year(2022)

select *
from netflix
where release_year = 2020 and type = 'Movie'

--find the top 5 countries with the top content on netflix

SELECT UNNEST(STRING_TO_ARRAY(country,',')),
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5

-- 5 IDENTIFY THE LONGEST MOVIE
SELECT *
from netflix
WHERE type = 'Movie'
and 
duration >= (select max(duration) from netflix)

-- 6 find the content added in the last 5 years
SELECT *
From netflix
WHERE 
TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- 7 find all the movies and Tv shows by director 'Rajiv chilaka' 
SELECT 
	*
	FROM netflix
WHERE director like '%Rajiv Chilaka%'

-- 8 list all tv shows with more than 5 seasons

SELECT * 
from netflix
where type = 'TV Show'
and 
duration > '5 Seasons'

-- 9 count the number of content items in each genre

select 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')),
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10 find each year and the average number of content release by india on netflix 
	-- return top 5 year with highest avg content release
	select 
	EXTRACT(YEAR FROM (TO_DATE(date_added, 'Month DD,YYYY'))) as date, 
	COUNT(*),
	ROUND(
    COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE  country = 'India')::numeric * 100,2) as avg_content_per_year
	from netflix
	where country = 'India'
group by 1

-- 11 List all the movies that are documentaries

SELECT * 
	
	FROM netflix
where type = 'Movie'
AND 
listed_in like '%Documentaries%'

-- 12 find all the content eithout a director

SELECT * 
FROM 
netflix
WHERE director is null

-- 13 find how many movies actor 'Salaman Khan' appeared in the last
-- ten years
SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')),
	COUNT(type)
	FROM netflix
WHERE type = 'Movie' 
	AND 
	country ILIKE '%India'
GROUP BY 1
order by 2 desc
limit 10

-- Ccategorize the content based on the presence of key words 'kill' and  
'violence' in the description field. label content containing these key words as'Bad'
and all other content as'Good'.Count how many items fall into each category

	WITH new_table AS (
SELECT * ,CASE WHEN description ILIKE '%kill%'
or description ILIKE '%violence%' THEN 'Bad film' 
	Else 'Good Content' end category
	FROM netflix
	)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1