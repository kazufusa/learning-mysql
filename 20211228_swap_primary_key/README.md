# Swap primary keys with CASE statement

I tried following SQL.

```sql
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id   INTEGER NOT NULL PRIMARY KEY,
  name TEXT
);

INSERT INTO users (id, name) VALUES
  (1, 'alpha'),
  (2, 'beta'),
  (3, 'gamma')
;

SELECT * FROM users;

UPDATE users SET id = CASE WHEN id = 1 THEN 2 ELSE 1 END WHERE id IN (1,2);

SELECT * FROM users;
```

## MySQL

Failed.

```sh
$ docker run --rm --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -v ${PWD}:/work -w /work -d mysql:latest
$ docker exec -it some-mysql mysql -uroot -pmy-secret-pw -D database -e 'source ./swap.sql;'
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------+
| id | name  |
+----+-------+
|  1 | alpha |
|  2 | beta  |
|  3 | gamma |
+----+-------+
ERROR 1062 (23000) at line 15 in file: './swap.sql': Duplicate entry '2' for key 'users.PRIMARY'
```

## SQLite3

Failed.

```sh
$ sqlite3 test.sqlite3 < swap.sql
1|alpha
2|beta
3|gamma
Error: near line 14: UNIQUE constraint failed: users.id
1|alpha
2|beta
3|gamma
```
