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
