-- Creating a table by splitting genres for each film into separate rows.
CREATE TEMP TABLE imdb_genres AS (
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 1)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 2)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 3)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 4)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 5)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 6)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 7)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 8)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 9)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 10)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 11)) AS genre
	FROM imdb_movies
	
	UNION
	
	SELECT imdb_id,
		TRIM(split_part(genres, ',', 12)) AS genre
	FROM imdb_movies
);


-- Removing NULL values.
DELETE FROM imdb_genres
WHERE genre = '';

DELETE FROM imdb_genres
WHERE genre IS NULL;


-- These two queries show that the IMDb and Letterboxd datasets both use the same genres.
SELECT genre, COUNT(*)
FROM imdb_genres
GROUP BY genre;

SELECT genre, COUNT(*)
FROM letterboxd_genres
GROUP BY genre;


-- Joining the IMDb and Letterboxd genre data to the id_match table.
CREATE TEMP TABLE movie_genres_temp AS (
	SELECT id.imdb_id, id.letterboxd_id,
		imdb.genre
	FROM id_match id
	LEFT JOIN imdb_genres imdb
		ON id.imdb_id = imdb.imdb_id
	
	UNION
	
	SELECT id.imdb_id, id.letterboxd_id,
		lb.genre
	FROM id_match id
	LEFT JOIN letterboxd_genres lb
		ON id.letterboxd_id = lb.id
);

DROP TABLE imdb_genres;

CREATE TEMP TABLE movie_genres AS (
	SELECT mg.imdb_id, mg.letterboxd_id, mg.genre,
		imdb.imdb_rating,
		lb.rating AS letterboxd_rating
	FROM movie_genres_temp mg
	LEFT JOIN imdb_movies imdb
		ON mg.imdb_id = imdb.imdb_id
	LEFT JOIN letterboxd_movies lb
		ON mg.letterboxd_id = lb.id
);

DROP TABLE movie_genres_temp;

DELETE FROM movie_genres
WHERE genre IS NULL;


-- Removing duplicate entries in movie_genres table.
CREATE TEMP TABLE row_num_movie_genres AS (
	SELECT *,
		ROW_NUMBER() OVER (ORDER BY imdb_id, letterboxd_id) AS row_num
	FROM movie_genres
);

-- Run this query until there are no duplicates left to delete.
DELETE FROM row_num_movie_genres
WHERE row_num IN (
	SELECT MAX(row_num) AS row_num
	FROM row_num_movie_genres
	GROUP BY imdb_id, letterboxd_id, genre
	HAVING COUNT(*) > 1
);

DROP TABLE movie_genres;

SELECT *
INTO movie_genres
FROM row_num_movie_genres;

DROP TABLE row_num_movie_genres;

ALTER TABLE movie_genres
DROP COLUMN row_num;



-- Created a table showing the average imdb rating and average letterboxd rating for each genre.
SELECT genre,
	COUNT(*) AS movie_count,
	ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
	ROUND(AVG(letterboxd_rating)*2, 2) AS avg_adjusted_letterboxd_rating
FROM movie_genres
GROUP BY genre
ORDER BY 2 DESC;

