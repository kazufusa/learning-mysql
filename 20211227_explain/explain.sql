CREATE TABLE IF NOT EXISTS CountryLanguage
  (
    id          INT NOT NULL PRIMARY KEY,
    name        VARCHAR(256),
    CountryCode INT,
    IsOfficial  CHAR(1)
  )
;

CREATE TABLE IF NOT EXISTS Country
  (
    id      INT NOT NULL PRIMARY KEY,
    name    VARCHAR(256),
    Code    INT,
    Capital INT
  )
;

CREATE TABLE IF NOT EXISTS City
  (
    id   INT NOT NULL PRIMARY KEY,
    name VARCHAR(256)
  )
;

EXPLAIN SELECT * FROM
  CountryLanguage
    JOIN Country ON CountryLanguage.CountryCode = Country.Code
    JOIN City ON Country.Capital = City.ID
WHERE CountryLanguage.IsOfficial = 'T';

DROP TABLE IF EXISTS CountryLanguage, Country, City;
