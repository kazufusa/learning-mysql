# EXPLAIN and JOIN

## Start mysql server with Docker

```sh
$ docker run --rm --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw MYSQL_DATABASE=database -d mysql:latest
```

## Try EXPLAIN SQL including JOIN

```sql
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

DROP TABLE IF EXISTS CountryLanguage;
DROP TABLE IF EXISTS Country;
DROP TABLE IF EXISTS City;
```

```sh
$ mysql -uroot -pmy-secret-pw -D database --protocol tcp < ./explain.sql
mysql: [Warning] Using a password on the command line interface can be insecure.
id	select_type	table	partitions	type	possible_keys	key	key_len	ref	rows	filtered	Extra
1	SIMPLE	CountryLanguage	NULL	ALL	NULL	NULL	NULL	NULL	1	100.00	Using where
1	SIMPLE	Country	NULL	ALL	NULL	NULL	NULL	NULL	1	100.00	Using where; Using join buffer (hash join)
1	SIMPLE	City	NULL	eq_ref	PRIMARY	PRIMARY	4	database.Country.Capital	1	100.00	NULL
```
