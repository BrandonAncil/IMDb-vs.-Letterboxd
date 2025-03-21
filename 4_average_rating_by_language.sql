CREATE TEMP TABLE primary_languages AS (
	SELECT *
	FROM letterboxd_languages
	WHERE type != 'Spoken language'
);


-- Join languages table onto id_match table.
SELECT id.letterboxd_id, id.imdb_id,
	pl.language
FROM id_match id
LEFT JOIN primary_languages pl
	ON id.letterboxd_id = pl.id
WHERE pl.language IS NOT NULL;


-- Filling in null values from previous join with IMDb genre data.
SELECT id.letterboxd_id, id.imdb_id,
	imdb.original_language
FROM id_match id
LEFT JOIN primary_languages pl
	ON id.letterboxd_id = pl.id
LEFT JOIN imdb_movies imdb
	ON id.imdb_id = imdb.imdb_id
WHERE pl.language IS NULL;


-- Replacing abbreviated strings with full text.
SELECT id.letterboxd_id, id.imdb_id,
	CASE WHEN imdb.original_language = 'hy' THEN 'Armenian'
		WHEN imdb.original_language = 'az' THEN 'Azerbaijani'
		WHEN imdb.original_language = 'eu' THEN 'Basque'
		WHEN imdb.original_language = 'zh' THEN 'Chinese'
		WHEN imdb.original_language = 'cs' THEN 'Czech'
		WHEN imdb.original_language = 'da' THEN 'Danish'
		WHEN imdb.original_language = 'nl' THEN 'Dutch'
		WHEN imdb.original_language = 'dz' THEN 'Dzongkha'
		WHEN imdb.original_language = 'en' THEN 'English'
		WHEN imdb.original_language = 'et' THEN 'Estonian'
		WHEN imdb.original_language = 'fi' THEN 'Finnish'
		WHEN imdb.original_language = 'fr' THEN 'French'
		WHEN imdb.original_language = 'ka' THEN 'Georgian'
		WHEN imdb.original_language = 'de' THEN 'German'
		WHEN imdb.original_language = 'el' THEN 'Greek (modern)'
		WHEN imdb.original_language = 'hi' THEN 'Hindi'
		WHEN imdb.original_language = 'hu' THEN 'Hungarian'
		WHEN imdb.original_language = 'is' THEN 'Icelandic'
		WHEN imdb.original_language = 'ik' THEN 'Inuktitut'
		WHEN imdb.original_language = 'it' THEN 'Italian'
		WHEN imdb.original_language = 'ja' THEN 'Japanese'
		WHEN imdb.original_language = 'kn' THEN 'Kannada'
		WHEN imdb.original_language = 'ko' THEN 'Korean'
		WHEN imdb.original_language = 'la' THEN 'Latin'
		WHEN imdb.original_language = 'lv' THEN 'Latvian'
		WHEN imdb.original_language = 'lt' THEN 'Lithuanian'
		WHEN imdb.original_language = 'mk' THEN 'Macedonian'
		WHEN imdb.original_language = 'mr' THEN 'Marathi'
		WHEN imdb.original_language = 'no' THEN 'Norwegian'
		WHEN imdb.original_language = 'fa' THEN 'Persian (Farsi)'
		WHEN imdb.original_language = 'pl' THEN 'Polish'
		WHEN imdb.original_language = 'pt' THEN 'Portuguese'
		WHEN imdb.original_language = 'ro' THEN 'Romanian'
		WHEN imdb.original_language = 'ru' THEN 'Russian'
		WHEN imdb.original_language = 'sr' THEN 'Serbian'
		WHEN imdb.original_language = 'sh' THEN 'Serbo-Croatian'
		WHEN imdb.original_language = 'sk' THEN 'Slovak'
		WHEN imdb.original_language = 'es' THEN 'Spanish'
		WHEN imdb.original_language = 'sv' THEN 'Swedish'
		WHEN imdb.original_language = 'tl' THEN 'Tagalog'
		WHEN imdb.original_language = 'th' THEN 'Thai'
		WHEN imdb.original_language = 'tr' THEN 'Turkish'
		WHEN imdb.original_language = 'uk' THEN 'Ukrainian'
		WHEN imdb.original_language = 'xx' THEN 'No spoken language'
		ELSE imdb.original_language END AS language
FROM id_match id
LEFT JOIN primary_languages pl
	ON id.letterboxd_id = pl.id
LEFT JOIN imdb_movies imdb
	ON id.imdb_id = imdb.imdb_id
WHERE pl.language IS NULL;


-- Creating a table with the union of the previous queries.
CREATE TEMP TABLE movie_languages AS (
	SELECT id.letterboxd_id, id.imdb_id,
		pl.language
	FROM id_match id
	LEFT JOIN primary_languages pl
		ON id.letterboxd_id = pl.id
	WHERE pl.language IS NOT NULL
	
	UNION
	
	SELECT id.letterboxd_id, id.imdb_id,
		CASE WHEN imdb.original_language = 'hy' THEN 'Armenian'
			WHEN imdb.original_language = 'az' THEN 'Azerbaijani'
			WHEN imdb.original_language = 'eu' THEN 'Basque'
			WHEN imdb.original_language = 'zh' THEN 'Chinese'
			WHEN imdb.original_language = 'cs' THEN 'Czech'
			WHEN imdb.original_language = 'da' THEN 'Danish'
			WHEN imdb.original_language = 'nl' THEN 'Dutch'
			WHEN imdb.original_language = 'dz' THEN 'Dzongkha'
			WHEN imdb.original_language = 'en' THEN 'English'
			WHEN imdb.original_language = 'et' THEN 'Estonian'
			WHEN imdb.original_language = 'fi' THEN 'Finnish'
			WHEN imdb.original_language = 'fr' THEN 'French'
			WHEN imdb.original_language = 'ka' THEN 'Georgian'
			WHEN imdb.original_language = 'de' THEN 'German'
			WHEN imdb.original_language = 'el' THEN 'Greek (modern)'
			WHEN imdb.original_language = 'hi' THEN 'Hindi'
			WHEN imdb.original_language = 'hu' THEN 'Hungarian'
			WHEN imdb.original_language = 'is' THEN 'Icelandic'
			WHEN imdb.original_language = 'ik' THEN 'Inuktitut'
			WHEN imdb.original_language = 'it' THEN 'Italian'
			WHEN imdb.original_language = 'ja' THEN 'Japanese'
			WHEN imdb.original_language = 'kn' THEN 'Kannada'
			WHEN imdb.original_language = 'ko' THEN 'Korean'
			WHEN imdb.original_language = 'la' THEN 'Latin'
			WHEN imdb.original_language = 'lv' THEN 'Latvian'
			WHEN imdb.original_language = 'lt' THEN 'Lithuanian'
			WHEN imdb.original_language = 'mk' THEN 'Macedonian'
			WHEN imdb.original_language = 'mr' THEN 'Marathi'
			WHEN imdb.original_language = 'no' THEN 'Norwegian'
			WHEN imdb.original_language = 'fa' THEN 'Persian (Farsi)'
			WHEN imdb.original_language = 'pl' THEN 'Polish'
			WHEN imdb.original_language = 'pt' THEN 'Portuguese'
			WHEN imdb.original_language = 'ro' THEN 'Romanian'
			WHEN imdb.original_language = 'ru' THEN 'Russian'
			WHEN imdb.original_language = 'sr' THEN 'Serbian'
			WHEN imdb.original_language = 'sh' THEN 'Serbo-Croatian'
			WHEN imdb.original_language = 'sk' THEN 'Slovak'
			WHEN imdb.original_language = 'es' THEN 'Spanish'
			WHEN imdb.original_language = 'sv' THEN 'Swedish'
			WHEN imdb.original_language = 'tl' THEN 'Tagalog'
			WHEN imdb.original_language = 'th' THEN 'Thai'
			WHEN imdb.original_language = 'tr' THEN 'Turkish'
			WHEN imdb.original_language = 'uk' THEN 'Ukrainian'
			WHEN imdb.original_language = 'xx' THEN 'No spoken language'
			ELSE imdb.original_language END AS language
	FROM id_match id
	LEFT JOIN primary_languages pl
		ON id.letterboxd_id = pl.id
	LEFT JOIN imdb_movies imdb
		ON id.imdb_id = imdb.imdb_id
	WHERE pl.language IS NULL
);


-- Deleting one duplicate row.
DELETE FROM movie_languages
WHERE letterboxd_id = 1105501
	AND imdb_id = 'tt1391548'
	AND language = 'French';

-- Updating movie_languages table.
UPDATE movie_languages
SET language = 'Greek (modern)'
WHERE language = 'Greek (modern)';

UPDATE movie_languages
SET language = 'Persian (Farsi)'
WHERE language = 'Persian (Farsi)';


-- Joining IMDb and Letterboxd ratings to languages table.
CREATE TEMP TABLE movie_languages_row_num AS (
	SELECT ml.letterboxd_id, ml.imdb_id, ml.language,
		imdb.imdb_rating,
		lb.rating AS letterboxd_rating,
		ROW_NUMBER() OVER (ORDER BY ml.letterboxd_id, ml.imdb_id) AS row_num
	FROM movie_languages ml
	LEFT JOIN imdb_movies imdb
		ON ml.imdb_id = imdb.imdb_id
	LEFT JOIN letterboxd_movies lb
		ON ml.letterboxd_id = lb.id
);


-- Run this query until there are no duplicates left to delete.
DELETE FROM movie_languages_row_num
WHERE row_num IN (
	SELECT MAX(row_num) AS row_num
	FROM movie_languages_row_num
	GROUP BY letterboxd_id, imdb_id, language
	HAVING COUNT(*) > 1
);


-- Replace movie_languages table with movie_languages_row_num table.
DROP TABLE movie_languages;

SELECT *
INTO movie_languages
FROM movie_languages_row_num;

DROP TABLE movie_languages_row_num;


-- Average ratings on IMDb and Letterboxd for each genre.
SELECT language,
	COUNT(*) AS movie_count,
	ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating,
	ROUND(AVG(letterboxd_rating)*2, 2) AS avg_adjusted_letterboxd_rating
FROM movie_languages
GROUP BY language;


-- Average ratings on IMDb and Letterboxd for English vs. foreign language films.
WITH english_ratings AS (
	SELECT 'IMDb' AS platform,
		ROUND(AVG(imdb_rating), 2) AS avg_rating_english
	FROM movie_languages
	WHERE language = 'English'
	
	UNION
	
	SELECT 'Letterboxd' AS platform,
		ROUND(AVG(letterboxd_rating)*2, 2) AS avg_rating_english
	FROM movie_languages
	WHERE language = 'English'
),
foreign_ratings AS (
	SELECT 'IMDb' AS platform,
		ROUND(AVG(imdb_rating), 2) AS avg_rating_foreign_language
	FROM movie_languages
	WHERE language NOT IN ('English', 'No spoken language')
	
	UNION
	
	SELECT 'Letterboxd' AS platform,
		ROUND(AVG(letterboxd_rating)*2, 2) AS avg_rating_foreign_language
	FROM movie_languages
	WHERE language NOT IN ('English', 'No spoken language')
)
SELECT e.platform,
	e.avg_rating_english,
	f.avg_rating_foreign_language
FROM english_ratings e
JOIN foreign_ratings f
	ON e.platform = f.platform

