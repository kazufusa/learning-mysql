# Swap primary keys with CASE statement

Following sql fails to swap primary keys.

```sql
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id   INTEGER NOT NULL PRIMARY KEY,
  name STRING
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
