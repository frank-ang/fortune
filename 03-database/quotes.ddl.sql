DROP DATABASE IF EXISTS demo;
CREATE DATABASE demo;
USE demo;

DROP TABLE IF EXISTS quotes;

CREATE TABLE IF NOT EXISTS quotes(
    id INT AUTO_INCREMENT,
    quote VARCHAR(2048) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=INNODB;

CREATE INDEX quote_author 
ON quotes (author);

CREATE INDEX quote_genre
ON quotes (genre);

LOAD DATA LOCAL INFILE '/tmp/quotes.csv'
    INTO TABLE quotes
	FIELDS TERMINATED BY ';' 
	IGNORE 1 ROWS
    (quote, author, genre)
    SET id = NULL;

SELECT COUNT(1) FROM quotes;
