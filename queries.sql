
USE recordstore;

DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS recordlabels;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS album_genre_bridge;




CREATE TABLE artists (
	artistID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255) NOT NULL,
	recordlabel VARCHAR(255),
	discoveredby int,
	FOREIGN KEY (discoveredby) REFERENCES artists(artistID),
	FOREIGN KEY (recordlabel) REFERENCES recordlabels(labelId)
);

CREATE TABLE recordlabels (
	labelID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255)
);

CREATE TABLE albums (
	albumID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255) NOT NULL,
	releaseDate DATE NOT NULL,
	artistID INT NOT NULL,
	cost FLOAT(6, 2) NOT NULL,
--	genre INT NOT NULL,
	FOREIGN KEY (artistID) REFERENCES artists(artistID)
--	FOREIGN KEY (genre) REFERENCES genres(genreID)
);

CREATE TABLE genres (
	genreID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255)
);

CREATE TABLE album_genre_bridge (
	albumID INT NOT NULL,
	genreID INT NOT NULL,
	FOREIGN KEY (albumID) REFERENCES albums(albumID),
	FOREIGN KEY (genreID) REFERENCES genres(genreID)
);

-- Insert statements
INSERT INTO artists
	(name, recordlabel, discoveredby) 
VALUES 
	("Nine Inch Nails", 1, null),
	("Tool",  2, null),
	("Radiohead", 3, null),
	("Pop Will Eat Itself", 4, 1),
	("Dream Theater", 5, null),
	("Rammstein", 5, null),
	("Sleepytime Gorilla Museum", 7, null),
	("Amy Winehouse", 1, null),
	("Clipping", 4, null)
;

INSERT INTO albums
	(name, releaseDate, artistID, cost)
VALUES
	("The Downward Sprial", "1994-05-25", 1,  19.99),
	("The Fragile", "1999-07-27", 1, 19.99),
	("10000 Days", "2009-03-12", 2, 21.95),
	("Kid A", "2003-04-11", 3, 19.99),
	("Amnesiac", "2009-06-07", 3, 12.95),
	("Pop Will Eat Itself", "1976-03-08", 4, 5.95),
	("Glass Prison", "2009-04-30", 5, 15.95),
	("Liebe ist für alle da", "2016-11-12", 6, 21.95),
	("Of Natural History", "2013-01-01", 7, 22.95),
	("Frank", "2007-06-03", 8, 18.95),
	("Clipping", "2018-05-24", 9, 14.95)
;

INSERT INTO album_genre_bridge
	(albumID, genreID)
VALUES
	(1,1),
	(2,1),
	(2,2),
	(3,2),
	(3,3),
	(3,4),
	(4,6),
	(4,7),
	(5,6),
	(5,7),
	(6,1),
	(7,2),
	(8,1),
	(8,4),
	(9,1),
	(10, 3),
	(11,8)
;

INSERT INTO recordlabels
	(name)
VALUES
	("Interscope"),
	("Volcano"),
	("Ticker Tape"),
	("Nothing"),
	("Caroline"),
	("Roadrunner"),
	("Universal")
;

INSERT INTO genres
	(name)
VALUES
	("Industrial"),
	("Progressive Rock"),
	("Rock"),
	("Metal"),
	("Country"),
	("Art Rock"),
	("Experimental"),
	("Rap")
;


-- Inserting new album into albums and creating an entry in the album_genre junction table.  Since albums and genres are a many to many relationship



INSERT INTO albums
	(name, releaseDate, artistID, cost)
VALUES
	("Hesitation Marks", "2016-12-22", 1, 19.99)
;
SET @last_inserted_id = LAST_INSERT_ID();

INSERT INTO album_genre_bridge
	(albumID, genreID)
	SELECT @last_inserted_id, genreID 
	FROM genres g
	WHERE 
		g.name IN("Industrial", "Rock")
	;


-- Select all albums by artist

SELECT art.name as artist, alb.name as album, alb.releaseDate as "Release Date" from artists art
INNER JOIN albums alb on art.artistID = alb.artistID
where art.name = "Nine Inch Nails"
order by alb.name 




-- Select all albums by artist released in 2016
SELECT art.name as artist, alb.name as album, alb.releaseDate as "Release Date" from artists art
INNER JOIN 
	albums alb ON art.artistID = alb.artistID
where 
	art.name = "Nine Inch Nails" AND 
	EXTRACT(YEAR FROM alb.releaseDate) = 2016

-- Select all albums that cost less than $20

SELECT 
	art.name as Artist, alb.name as Album, alb.releaseDate as "Release Date", CONCAT("$", alb.cost) as Cost
FROM 
	artists art 
INNER JOIN 
	albums alb 
	ON art.artistID = alb.artistID 
WHERE 
	alb.cost < 20 
ORDER BY 
	alb.cost;

-- Select all albums that are less than 70% of the price of the most expensive album
SELECT 
	art.name as Artist, alb.name as Album, alb.releaseDate as "Release Date", CONCAT("$", alb.cost) as Cost
FROM 
	artists art 
INNER JOIN 
	albums alb 
	ON art.artistID = alb.artistID 
WHERE 
	alb.cost < (SELECT MAX(cost) from albums) * .7    
ORDER BY alb.cost;


-- Classifying albums into categories based on age using case statements 
SELECT 
	art.name as Artist, alb.name as Album, alb.releaseDate as "Release Date",
    CASE
    	WHEN EXTRACT(year FROM alb.releaseDate) > 2000 THEN "Contemporary"
        ELSE "Classic"
	END as Age                  
FROM 
	artists art 
INNER JOIN 
	albums alb 
	ON art.artistID = alb.artistID 
ORDER BY art.name;



-- Selecting all artists and all albums (contrived example)
SELECT name from artists
UNION
SELECT name from albums

-- Select the newest album


SELECT max(releaseDate) from albums as Latest

-- Select the name of the artist and album that was most recently released


SELECT art.name as Artist, alb.name as Album, alb.releaseDate 
FROM 
	artists art
INNER JOIN
	albums alb ON
    art.artistID = alb.artistID
WHERE
	releaseDate = (SELECT MAX(releaseDate) from albums);





-- Select all artists who were discovered by another artist, and who discovered them (self join ex)
SELECT art.name as "Discovered Artist", art2.name as "Discoverer" 
FROM
	artists art
INNER JOIN
	artists art2 ON
	art.discoveredby = art2.artistID


-- Select all artists, and if the artist was discovered by another artist, select that too (more self join)
SELECT art.name as Artist, art2.name as Discoverer
FROM 
	artists art
LEFT JOIN artists art2 ON
	art.discoveredby = art2.artistID
ORDER BY art.name




-- Select all albums and  their genres. Concatenate genres if multiple

SELECT art.name as Artist, al.name as "Album Name", GROUP_CONCAT(gen.name SEPARATOR ", ")as Genres
FROM
	artists art
INNER JOIN 
	albums al ON
    art.artistID = al.artistID
INNER JOIN
	album_genre_bridge agb ON
    al.albumID = agb.albumID
INNER JOIN
	genres gen ON
    gen.genreID = agb.genreID
GROUP BY al.albumID
ORDER BY art.name

-- Produce a count of the number of albums released by month, year

SELECT EXTRACT(YEAR from releaseDate) as year, MONTHNAME(releaseDate) as month, count(*) 
FROM 
	albums 
GROUP BY YEAR(releaseDate), MONTH(releaseDate) desc


