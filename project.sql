
--  ***** Segment 1: Database - Tables, Columns, Relationships*****


-- Q1 What are the different tables in the database and how are they connected to each other in the database?
-- Ans Diffrent tables in the Database
-- movies
-- genre
-- director_mapping
-- role_mapping
-- names
-- rating
-- The relationships between these tables are based on primary key-foreign key connections. 
-- The movie ID is the primary key in the movie table and serves as a reference in the other tables. 
-- The genre, director, and actor tables use the movie ID as a foreign key to associate them with specific movies. 
-- Similarly, the name ID is used as a foreign key in the director_mapping and role_mapping tables to connect them with specific directors and actors. 
-- Finally, the movie ID is used as a foreign key in the ratings table to associate ratings with specific movies.

-- Q2 Find the total number of rows in each table of the schema.

SELECT TABLE_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';

###
-- director_mapping	    3867
-- genre	            14662
-- movie	            8082
-- names	            25755
-- ratings	            7927
-- role_mapping	        15287


-- Q3 Identify which columns in the movie table have null value

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'imdb'
  AND TABLE_NAME = 'movie'
  AND IS_NULLABLE = 'YES';
 
### 
-- found null in below given columns ( count mentioned) 
-- year 20
-- worlwide_gross_income  3724
-- languages 194
-- production_company 528


-- ***** segment 2 Movie Release Trends *****


-- Q1 Determine the total number of movies released each year and analyse the month-wise trend.

SELECT year,
       Count(title) AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY year;

SELECT Month(date_published) AS MONTH_NUM,
       Count(*)              AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY month_num
ORDER  BY month_num; 

###
--  In Year 2017 highest no. of movies were released i.e, 3052)
-- March has highest and December has least no. of films released.



-- Q2 Calculate the number of movies produced in the USA or India in the year 2019.


SELECT COUNT(*) AS movie_count
FROM movie
WHERE (country = 'USA' OR country = 'India')
  AND year = 2019; 

###  
-- Number of movies produced by USA or India for the last year i.e, 2019 is "887"  
  
  
-- ***** segment 3 Production Statistics and Genre Analysis *****


-- Q1 Retrieve the unique list of genres present in the dataset.
  
  
	SELECT DISTINCT genre
	FROM genre;

###    
-- Unique list of genres
-- Drama
-- Fantasy
-- Thriller
-- comedy
-- Horror
-- Family 
-- Romance
-- Adventure
-- Action 
-- Sci-Fic
-- Crime
-- Mystery
-- Others


-- Q2 Identify the genre with the highest number of movies produced overall ?

SELECT genre, COUNT(*) AS movie_count
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 1;

###
-- Drama genre had the highest movies produced overall i.e, 4285.


-- Q3 Determine the count of movies that belong to only one genre.

SELECT COUNT(*) AS movie_count
FROM (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(*) = 1
) AS single_genre_movies;

###
-- 3289 movies have exactly one genre.

-- Q4 Calculate the average duration of movies in each genre.

SELECT genre, AVG(duration) AS avg_duration
FROM movie
JOIN genre ON movie.id = genre.movie_id
GROUP BY genre;

###
--  Duration of Action movies is highest with duration of 112.88 mins whereas Horror movies have least with duration 92.72 mins.


-- Q5 Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.

SELECT genre, movie_count, 
       RANK() OVER (ORDER BY movie_count DESC) AS genre_rank
FROM (
    SELECT genre, COUNT(*) AS movie_count
    FROM genre
    GROUP BY genre
) AS genre_counts
WHERE genre = 'thriller';

###
-- Thriller genre has 1st rank with 1484 movies.


-- ***** Segment 4: Ratings Analysis and Crew Members *****


-- q1 Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).

	SELECT MIN(avg_rating) AS min_avg_rating, MAX(avg_rating) AS max_avg_rating,
		   MIN(total_votes) AS min_total_votes, MAX(total_votes) AS max_total_votes,
		   MIN(median_rating) AS min_median_rating, MAX(median_rating) AS max_median_rating
	FROM ratings;
    
###
-- Rtaing Table     minimum      maximum
-- avg_rating         1.0         10.0
-- total_votes        100         725138
-- median_rating       1          10     

-- q2 Identify the top 10 movies based on average rating.

SELECT     
   title,
   avg_rating,
   Rank() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM       ratings AS rat
INNER JOIN movie   AS mov
ON         mov.id = rat.movie_id 
limit 10;

###
-- Top ten movies based on average rating
-- Kirket
-- Love in Kilnerry
-- Gini Helida Kathe
-- Runam
-- Fan
-- Andriod kunjappan Version 5.25
-- Yeh Suhagrat impossible
-- Safe
-- The Brighton Miracle
-- Shibu


-- Q3 Summarise the ratings table based on movie counts by median ratings.

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;

###
--  Movies with a median rating of 7 is highest in number.


-- Q4 Identify the production house that has produced the most number of hit movies (average rating > 8).


SELECT production_company,
      Count(movie_id) AS movie_count, 
      Rank() OVER( ORDER BY Count(movie_id) DESC ) AS prod_company_rank
FROM ratings AS rat
     INNER JOIN movie AS mov
     ON mov.id = rat.movie_id
WHERE avg_rating > 8
     AND production_company IS NOT NULL
GROUP BY production_company;

###
-- Dream Warrior Pictures and National Theatre Live production both have the most number of hit movies i.e, 3 movies with average rating > 8


-- Q5 Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

SELECT g.genre, COUNT(*) AS movie_count
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE m.country = 'USA'
  AND MONTH(m.date_published) = 3
  AND YEAR(m.date_published) = 2017
  AND r.total_votes > 1000
GROUP BY g.genre;

###
-- Drama genre had the maximum no. of releases with 16 movies whereas Family genre was least with 1 movie only.


-- Q6 Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

SELECT title, avg_rating, genre
FROM movie AS mov
     INNER JOIN genre AS gen
           ON gen.movie_id = mov.id
     INNER JOIN ratings AS rat
               ON rat.movie_id = mov.id
WHERE avg_rating > 8
	  AND title LIKE 'THE%'
ORDER BY avg_rating DESC;

###
--  There are 8 movies that start with the word ‘The’ and which have an average rating > 8.


-- ***** Segment 5: Crew Analysis*****


-- Q1 Identify the columns in the names table that have null values

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'imdb'
  AND TABLE_NAME = 'names'
  AND IS_NULLABLE = 'YES';
 
 ###
 -- Their are 3 columns in the name table which has null values 
 -- height
 -- date_of_birth
 -- known_for_movies
 
 
 -- Q2 Determine the top three directors in the top three genres with movies having an average rating > 8.
  

WITH top_3_genres
AS (
    SELECT genre,
	   Count(mov.id) AS movie_count ,
	   Rank() OVER(ORDER BY Count(mov.id) DESC) AS genre_rank
    FROM movie AS mov
	   INNER JOIN genre AS gen
			 ON gen.movie_id = mov.id
	   INNER JOIN ratings AS rat
			 ON rat.movie_id = mov.id  
    WHERE avg_rating > 8
    GROUP BY genre limit 3 
    )
SELECT 
    nam.NAME AS director_name ,
	Count(dm.movie_id) AS movie_count
FROM director_mapping AS dm
       INNER JOIN genre gen using (movie_id)
       INNER JOIN names AS nam
       ON nam.id = dm.name_id
       INNER JOIN top_3_genres using (genre)
       INNER JOIN ratings using (movie_id)
WHERE avg_rating > 8
GROUP BY name
ORDER BY movie_count DESC limit 3 ;

###
-- top 3 meniotned below with movie count
-- James Mangold	4
-- Anthony Russo	3
-- Soubin Shahir	3



-- Q3 Find the top two actors whose movies have a median rating >= 8.

SELECT n.name AS actor, COUNT(*) AS movie_count
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN ratings r ON rm.movie_id = r.movie_id
WHERE r.median_rating >= 8
  AND rm.category = 'actor'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 2;

###
-- top two actor below with movie_count 
-- Mammootty	8
-- Mohanlal	5


-- Q4 	Identify the top three production houses based on the number of votes received by their movies

SELECT m.production_company, SUM(r.total_votes) AS total_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.production_company
ORDER BY total_votes DESC
LIMIT 3;

###

-- Marvel Studios, Twentieth Century Fox and Warner Bros are top three production houses based on the number of votes received by their movies.


-- Q5 Rank actors based on their average ratings in Indian movies released in India.

SELECT nam.name AS actor, AVG(r.avg_rating) AS average_rating
FROM names AS nam
JOIN role_mapping AS rm ON nam.id = rm.name_id
JOIN movie AS mov ON rm.movie_id = mov.id
JOIN ratings AS r ON mov.id = r.movie_id
WHERE mov.country = 'India'
GROUP BY actor
ORDER BY average_rating DESC;

### 
-- rank 1 of the actor is gopi krishna 


-- Q6 Identify the top five actresses in Hindi movies released in India based on their average ratings.

SELECT n.name, AVG(r.avg_rating) AS average_rating
FROM names AS n
JOIN role_mapping AS rm ON n.id = rm.name_id
JOIN movie AS m ON rm.movie_id = m.id
JOIN ratings AS r ON m.id = r.movie_id
WHERE m.country = 'India' AND m.languages LIKE '%Hindi%' AND rm.category = 'actress'
GROUP BY n.name
ORDER BY average_rating DESC
LIMIT 5;

###
-- Top five actresses in Hindi movies
-- Pranati Rai Prakash   9.4
-- Leera Kaljai          9.2
-- Puneet Sikka          8.7
-- Bhairavi Athavle      8.4
-- Radhika Apte          8.4


-- ***** segment 6


-- Q1 Classify thriller movies based on average ratings into different categories.

SELECT m.title, AVG(r.avg_rating) AS average_rating,
    CASE
        WHEN AVG(r.avg_rating) >= 8.0 THEN 'Excellent'
        WHEN AVG(r.avg_rating) >= 7.0 THEN 'Good'
        WHEN AVG(r.avg_rating) >= 6.0 THEN 'Average'
        ELSE 'Below Average'
    END AS rating_category
FROM movie AS m
JOIN genre AS g ON m.id = g.movie_id
JOIN ratings AS r ON m.id = r.movie_id
WHERE g.genre = 'Thriller'
GROUP BY m.title
ORDER BY average_rating DESC;

###
-- If we go about taking the counts for each category
-- Rating category        counts  
-- Hit movies	            166
-- Flop movies	            492
-- one-time-watch movies	785
-- superhit movies	         39


-- Q2 analyse the genre-wise running total and moving average of the average movie duration.

SELECT
    genre.genre,
    m.duration,
    SUM(m.duration) OVER (PARTITION BY genre.genre ORDER BY m.year) AS running_total,
    AVG(m.duration) OVER (PARTITION BY genre.genre ORDER BY m.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_average
FROM
    movie AS m
JOIN
    genre ON m.id = genre.movie_id
WHERE
    m.duration IS NOT NULL
ORDER BY
    genre.genre, m.year;
    
###
-- Round is good to have and not a must have; Same thing applies to sorting

	
    
-- Q3 Identify the five highest-grossing movies of each year that belong to the top three genres.

WITH top_genres AS (
    SELECT genre, COUNT(*) AS movie_count
    FROM genre
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
)
SELECT m.year, g.genre, m.title, m.worlwide_gross_income
FROM (
    SELECT year, genre, MAX(worlwide_gross_income) AS max_income
    FROM movie AS m
    JOIN genre AS g ON m.id = g.movie_id
    WHERE g.genre IN (SELECT genre FROM top_genres)
    GROUP BY year, genre
) AS max_gross
JOIN movie AS m ON max_gross.year = m.year AND max_gross.max_income = m.worlwide_gross_income
JOIN genre AS g ON m.id = g.movie_id AND g.genre = max_gross.genre
ORDER BY m.year, g.genre, m.worlwide_gross_income DESC
LIMIT 5;

###
-- Five highest-grossing movies of each year
-- The Healer            2017    Comedy
-- Shatamanam Bhavati    2017    Drama
-- Gi-eok-ui bam         2017    Thriller
-- La fuitina sbagliata  2018    Comedy
-- Antiny & Cleopatra    2018    Drama

-- Q4 Determine the top two production houses that have produced the highest number of hits among multilingual movies

WITH production_company_detail
     AS (SELECT production_company,
                Count(*) AS movie_count
         FROM movie AS mov
                INNER JOIN ratings AS rat
		      ON rat.movie_id = mov.id
         WHERE median_rating >= 8
	       AND production_company IS NOT NULL
               AND Position(',' IN languages) > 0
         GROUP BY production_company
         ORDER BY movie_count DESC)
SELECT *,
       Rank() over( ORDER BY movie_count DESC) AS prod_comp_rank
FROM production_company_detail LIMIT 2;

###
-- Star Cinema and Twentieth Century Fox are the top 2 production houses that have produced the highest number of hits.



-- Q5 Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

SELECT n.name, COUNT(*) AS super_hit_count
FROM names AS n
JOIN role_mapping AS rm ON n.id = rm.name_id
JOIN movie AS m ON rm.movie_id = m.id
JOIN ratings AS r ON m.id = r.movie_id
JOIN genre AS g ON m.id = g.movie_id
WHERE rm.category = 'actress'
  AND g.genre = 'Drama'
  AND r.avg_rating > 8.0
GROUP BY n.name
ORDER BY super_hit_count DESC
LIMIT 3;

###
-- Parvathy Thiruvothu, Susan Brown and Amanda Lawrence are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre.


-- Q6 Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

SELECT n.name AS director_name, COUNT(*) AS movie_count,
       AVG(m.duration) AS average_duration,
       AVG(r.avg_rating) AS average_rating
FROM names AS n
JOIN director_mapping AS dm ON n.id = dm.name_id
JOIN movie AS m ON dm.movie_id = m.id
JOIN ratings AS r ON m.id = r.movie_id
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 9;

###
-- The top nine directors based on the number of movies are:
-- A.L.Vijay
-- Andrew Jones
-- Chris Strokes
-- Justin Price
-- Jesse V. Johnson
-- Steven Soderbergh
-- Sion Sono
-- Ozgur Bakar
-- Sam Liu























