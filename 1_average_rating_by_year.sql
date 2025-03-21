-- Creating a temp table of imdb ids and their corresponding ratings (Using MIN(imdb_rating) produces the same results.)
CREATE TEMP TABLE imdb_movie_ratings AS (
	SELECT imdb_id,
		MAX(imdb_rating) AS imdb_rating
	FROM imdb_movies
	GROUP BY imdb_id
);


-- Creating a temp table with both letterboxd and imdb ids, the release year, and the ratings on both letterboxd and imdb.
CREATE TEMP TABLE movie_ratings AS (
	SELECT id.letterboxd_id, id.imdb_id,
		lb.date AS release_year,
		lb.rating AS letterboxd_rating,
		imdb.imdb_rating AS imdb_rating
	FROM id_match id
	LEFT JOIN letterboxd_movies lb
		ON id.letterboxd_id = lb.id
	LEFT JOIN imdb_movie_ratings imdb
		ON id.imdb_id = imdb.imdb_id
);

DROP TABLE imdb_movie_ratings;


-- Average rating overall on imdb and letterboxd.
SELECT ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
	ROUND(AVG(letterboxd_rating)*2, 2) AS avg_adjusted_letterboxd_rating
FROM movie_ratings;

CREATE TABLE avg_ratings AS (
	SELECT ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
		ROUND(AVG(letterboxd_rating)*2, 2) AS avg_adjusted_letterboxd_rating
	FROM movie_ratings
);


-- Average ratings by decade.
SELECT FLOOR(release_year/10)*10 AS decade,
	COUNT(*) AS movie_count,
	ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
	ROUND(AVG(letterboxd_rating)*2, 2) AS avg_adjusted_letterboxd_rating,
	ROUND(AVG(imdb_rating), 2) - ROUND(AVG(letterboxd_rating)*2, 2) AS rating_differential
FROM movie_ratings
GROUP BY FLOOR(release_year/10)*10
ORDER BY 1 DESC;


-- Average ratings by year.
SELECT release_year,
	COUNT(*) AS movie_count,
	ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
	ROUND(AVG(letterboxd_rating)*2, 2) AS avg_adjusted_letterboxd_rating,
	ROUND(AVG(imdb_rating), 2) - ROUND(AVG(letterboxd_rating)*2, 2) AS rating_differential
FROM movie_ratings
GROUP BY release_year
ORDER BY 1 DESC;

