/* For this project, I am only looking at films that are in both IMDb and Letterboxd's datasets with at least 100 ratings on IMDb.
	The number of ratings on Letterboxd was not included in the dataset. */

ALTER TABLE tmdb_all_movies RENAME TO imdb_movies;

ALTER TABLE imdb_movies RENAME COLUMN "cast" to actors;

ALTER TABLE movies RENAME TO letterboxd_movies;

ALTER TABLE actors RENAME TO letterboxd_actors;

ALTER TABLE crew RENAME TO letterboxd_crew;

ALTER TABLE genres RENAME TO letterboxd_genres;

ALTER TABLE languages RENAME TO letterboxd_languages;

DELETE FROM letterboxd_movies WHERE rating IS NULL;

DELETE FROM imdb_movies WHERE imdb_rating IS NULL;

DELETE FROM imdb_movies WHERE imdb_votes < 100;


-- Removing columns from imdb_movies table that I will not be using.

ALTER TABLE imdb_movies ADD COLUMN release_year integer;

UPDATE imdb_movies SET release_year = EXTRACT(YEAR from release_date);

ALTER TABLE imdb_movies DROP COLUMN release_date;

ALTER TABLE imdb_movies DROP COLUMN vote_average;

ALTER TABLE imdb_movies DROP COLUMN vote_count;

ALTER TABLE imdb_movies DROP COLUMN production_companies;

ALTER TABLE imdb_movies DROP COLUMN production_countries;

ALTER TABLE imdb_movies DROP COLUMN spoken_languages;

ALTER TABLE imdb_movies DROP COLUMN director_of_photography;

ALTER TABLE imdb_movies DROP COLUMN writers;

ALTER TABLE imdb_movies DROP COLUMN producers;

ALTER TABLE imdb_movies DROP COLUMN music_composer;

ALTER TABLE imdb_movies DROP COLUMN poster_path;


-- Letterboxd Data Cleaning

DELETE FROM letterboxd_movies
WHERE id IN (
	SELECT MAX(id)
	FROM letterboxd_movies
	GROUP BY name, date, tagline, description, minute, rating
	HAVING COUNT(*) > 1
);

UPDATE letterboxd_movies
SET name = TRIM(name);

UPDATE letterboxd_movies
SET name = SUBSTRING(name, 2)
WHERE id = '1074369';


-- IMDb Data Cleaning

UPDATE imdb_movies
SET title = TRIM(title);

UPDATE imdb_movies
SET title = original_title
WHERE id = '388624';

UPDATE imdb_movies
SET overview = NULL
WHERE overview = ' ';


-- Match Letterboxd ids with IMDb ids

CREATE TABLE id_match (
	letterboxd_id integer,
	imdb_id text
);

-- Insert where name, release year, and tagline are all equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON (lb.name = imdb.title OR lb.name = imdb.original_title)
		AND lb.date = imdb.release_year
		AND lb.tagline = imdb.tagline
	WHERE (lb.name, imdb.title, imdb.original_title, lb.date, imdb.release_year, lb.tagline, imdb.tagline) IS NOT NULL
);

-- Insert where name, release year, and description are all equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON (lb.name = imdb.title OR lb.name = imdb.original_title)
		AND lb.date = imdb.release_year
		AND lb.description = imdb.overview
	WHERE (lb.name, imdb.title, imdb.original_title, lb.date, imdb.release_year, lb.description, imdb.overview) IS NOT NULL
);

-- Insert where name, release year, and runtime are all equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON (lb.name = imdb.title OR lb.name = imdb.original_title)
		AND lb.date = imdb.release_year
		AND lb.minute = imdb.runtime
	WHERE (lb.name, imdb.title, imdb.original_title, lb.date, imdb.release_year, lb.minute, imdb.runtime) IS NOT NULL
);

-- Insert matches where release year is within 1 and runtime is within 3 minutes
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON lb.name = imdb.title
		AND ABS(lb.minute-imdb.runtime) <= 3
		AND ABS(imdb.release_year - lb.date) <= 1
	WHERE (lb.name, imdb.title, lb.minute, imdb.runtime, lb.date, imdb.release_year) IS NOT NULL
);

-- Insert matches where first 10 characters of the names are equal, release year within 1, runtime within 3 minutes, and either the description or tagline are equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON LEFT(lb.name, 10) = LEFT(imdb.title, 10)
		AND ABS(lb.minute-imdb.runtime) <= 3
		AND ABS(imdb.release_year - lb.date) <= 1
		AND (lb.description = imdb.overview OR lb.tagline = imdb.tagline)
	WHERE (lb.name, imdb.title, lb.minute, imdb.runtime, lb.date, imdb.release_year) IS NOT NULL
);


-- Match Letterboxd ids with IMDb ids again, using Regular Expression.

ALTER TABLE imdb_movies ADD title_regexp text;

UPDATE imdb_movies SET title_regexp = REGEXP_REPLACE(title, '[^a-zA-Z0-9]', '', 'g');

ALTER TABLE letterboxd_movies ADD name_regexp text;

UPDATE letterboxd_movies SET name_regexp = REGEXP_REPLACE(name, '[^a-zA-Z0-9]', '', 'g');

UPDATE imdb_movies SET title_regexp = NULL WHERE title_regexp = '';

UPDATE letterboxd_movies SET name_regexp = NULL WHERE name_regexp = '';

-- Insert where name, release year, and tagline are all equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON lb.name_regexp = imdb.title_regexp
		AND lb.date = imdb.release_year
		AND lb.tagline = imdb.tagline
	WHERE (lb.name_regexp, imdb.title_regexp, lb.date, imdb.release_year, lb.tagline, imdb.tagline) IS NOT NULL
);

-- Insert where name, release year, and description are all equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON lb.name_regexp = imdb.title_regexp
		AND lb.date = imdb.release_year
		AND lb.description = imdb.overview
	WHERE (lb.name_regexp, imdb.title_regexp, lb.date, imdb.release_year, lb.description, imdb.overview) IS NOT NULL
);

-- Insert where name, release year, and runtime are all equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON lb.name_regexp = imdb.title_regexp
		AND lb.date = imdb.release_year
		AND lb.minute = imdb.runtime
	WHERE (lb.name_regexp, imdb.title_regexp, lb.date, imdb.release_year, lb.minute, imdb.runtime) IS NOT NULL
);

-- Insert matches where release year is within 1 and runtime is within 3 minutes
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON lb.name_regexp = imdb.title_regexp
		AND ABS(lb.minute-imdb.runtime) <= 3
		AND ABS(imdb.release_year - lb.date) <= 1
	WHERE (lb.name_regexp, imdb.title_regexp, lb.minute, imdb.runtime, lb.date, imdb.release_year) IS NOT NULL
);

-- Insert matches where first 10 characters of the names are equal, release year within 1, runtime within 3 minutes, and either the description or tagline are equal
INSERT INTO id_match (
	SELECT lb.id, imdb.imdb_id
	FROM letterboxd_movies lb
	JOIN imdb_movies imdb
	ON LEFT(lb.name_regexp, 10) = LEFT(imdb.title_regexp, 10)
		AND ABS(lb.minute-imdb.runtime) <= 3
		AND ABS(imdb.release_year - lb.date) <= 1
		AND (lb.description = imdb.overview OR lb.tagline = imdb.tagline)
	WHERE (lb.name_regexp, imdb.title_regexp, lb.minute, imdb.runtime, lb.date, imdb.release_year) IS NOT NULL
);


-- Remove duplicates from id_match table.

SELECT DISTINCT letterboxd_id, imdb_id
INTO id_match_1
FROM id_match;

DROP TABLE id_match;

SELECT *
INTO id_match
FROM id_match_1;

DROP TABLE id_match_1;

