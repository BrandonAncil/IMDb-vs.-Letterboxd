-- Creating a table of movies that grossed over $100 million.
CREATE TEMP TABLE imdb_highest_grossing_movies AS (
	SELECT imdb_id,
		MAX(imdb_rating) AS imdb_rating,
		MAX(revenue) - MAX(budget) AS gross
	FROM imdb_movies
	GROUP BY imdb_id
	HAVING MAX(revenue) > 0 AND MAX(budget) > 0
		AND MAX(revenue) - MAX(budget) > 100000000
);


-- Joining letterboxd_data onto 'highest grossing movies' table.
CREATE TEMP TABLE highest_grossing_movies AS (
	SELECT imdb.imdb_id,
		id.letterboxd_id,
		imdb.imdb_rating,
		lb.rating AS letterboxd_rating,
		imdb.gross
	FROM imdb_highest_grossing_movies imdb
	LEFT JOIN id_match id
		ON imdb.imdb_id = id.imdb_id
	LEFT JOIN letterboxd_movies lb
		ON id.letterboxd_id = lb.id
);

DROP TABLE imdb_highest_grossing_movies;


/* Looking at my 'highest_grossing_movies' table, 31 entries were not matched to a letterboxd id. I went through the letterboxd dataset manually to find the matching ids. Many of these entries were not in the letterboxd dataset due to them being released after the letterboxd dataset was last updated, other entries in the imdb dataset were TV shows and video games and were thus not in the letterboxd dataset. Overall, I found four matches and inserted them back into the 'highest_grossing_movies table. */

DELETE FROM highest_grossing_movies
WHERE letterboxd_id IS NULL;

INSERT INTO highest_grossing_movies
VALUES ('tt0190641', '1003628', '6.3', '3.53', '167700000'),
	('tt0210234', '1005845', '6.1', '3.23', '103949270'),
	('tt14539740', '1000938', '6.1', '2.77', '421750016'),
	('tt28814949', '1000948', '8', '4.31', '246656269');

INSERT INTO id_match
VALUES ('1003628', 'tt0190641'),
	('1005845', 'tt0210234'),
	('1000938', 'tt14539740'),
	('1000948', 'tt28814949');


/* Creating a table of the average ratings of films on IMDb and Letterboxd in four categories
	1) Average rating overall
	2) Average rating for films grossing over $100 million
	3) Average rating for top 1,000 highest grossing films
	4) Average rating for top 100 highest grossing films */

CREATE TEMP TABLE top_1000_highest_grossing_movies AS (
	SELECT *
	FROM highest_grossing_movies
	ORDER BY gross DESC
	LIMIT 1000
);

CREATE TEMP TABLE top_100_highest_grossing_movies AS (
	SELECT *
	FROM highest_grossing_movies
	ORDER BY gross DESC
	LIMIT 100
);

WITH avg_ratings_per_platform AS (
	SELECT 'IMDb' AS platform,
		avg_imdb_rating AS avg_rating
	FROM avg_ratings
	
	UNION ALL
	
	SELECT 'Letterboxd' AS platform,
		avg_adjusted_letterboxd_rating AS avg_rating
	FROM avg_ratings
),
avg_ratings_per_platform_hg AS (
	SELECT 'IMDb' AS platform,
		ROUND(AVG(imdb_rating), 2) AS avg_rating_highest_grossing
	FROM highest_grossing_movies
	
	UNION ALL
	
	SELECT 'Letterboxd' AS platform,
		ROUND(AVG(letterboxd_rating)*2, 2) AS avg_rating_highest_grossing
	FROM highest_grossing_movies
),
avg_ratings_per_platform_hg1000 AS (
	SELECT 'IMDb' AS platform,
		ROUND(AVG(imdb_rating), 2) AS avg_rating_top_1000_grossing
	FROM top_1000_highest_grossing_movies
	
	UNION ALL
	
	SELECT 'Letterboxd' AS platform,
		ROUND(AVG(letterboxd_rating)*2, 2) AS avg_rating_top_1000_grossing
	FROM top_1000_highest_grossing_movies
),
avg_ratings_per_platform_hg100 AS (
	SELECT 'IMDb' AS platform,
		ROUND(AVG(imdb_rating), 2) AS avg_rating_top_100_grossing
	FROM top_100_highest_grossing_movies
	
	UNION ALL
	
	SELECT 'Letterboxd' AS platform,
		ROUND(AVG(letterboxd_rating)*2, 2) AS avg_rating_top_100_grossing
	FROM top_100_highest_grossing_movies
)
SELECT t1.platform,
	t1.avg_rating,
	t2.avg_rating_highest_grossing,
	t3.avg_rating_top_1000_grossing,
	t4.avg_rating_top_100_grossing
FROM avg_ratings_per_platform t1
JOIN avg_ratings_per_platform_hg t2
	ON t1.platform = t2.platform
JOIN avg_ratings_per_platform_hg1000 t3
	ON t1.platform = t3.platform
JOIN avg_ratings_per_platform_hg100 t4
	ON t1.platform = t4.platform;


-- Querying the IMDb and Letterboxd ratings for films that grossed over $1 billion.
SELECT RANK() OVER (ORDER BY gross DESC) AS rank,
	lb.name,
	lb.date,
	hgm.imdb_rating,
	hgm.letterboxd_rating*2 AS adjusted_letterboxd_rating,
	hgm.gross
FROM highest_grossing_movies hgm
JOIN letterboxd_movies lb
	ON hgm.letterboxd_id = lb.id
WHERE gross > 1000000000;

