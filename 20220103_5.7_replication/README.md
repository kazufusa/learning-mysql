# Replication

1. 起動

```sh
$ docker-compose up -d --remove-orphans
```

2. add user to primary

```sh
$ docker-compose exec primary hostname -i
172.23.0.3
$ docker-compose exec primary mysql -uroot -pprimary-pw
> CREATE USER 'repl'@'172.23.0.3' IDENTIFIED BY 'repl';
> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.23.0.3';
> SELECT user,host FROM mysql.user;
+---------------+------------+
| user          | host       |
+---------------+------------+
| root          | %          |
| repl          | 172.23.0.3 |
| mysql.session | localhost  |
| mysql.sys     | localhost  |
| root          | localhost  |
+---------------+------------+
5 rows in set (0.00 sec)

> SHOW GRANTS FOR repl@172.23.0.3;
+-------------------------------------------------------+
| Grants for repl@172.23.0.3                            |
+-------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.23.0.3' |
+-------------------------------------------------------+
1 row in set (0.00 sec)

> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: ON.000003
         Position: 653
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: 68e8a513-6d2f-11ec-b6ca-0242ac170002:1-7
1 row in set (0.00 sec)
```

3. configure replica

```sh
$ docker-compose exec replica mysql -uroot -preplica-pw
> CHANGE MASTER TO
    MASTER_HOST='172.23.0.3',
    MASTER_PORT=3306,
    MASTER_LOG_FILE='ON.000003',
    MASTER_LOG_POS=653;
> START SLAVE USER = 'repl' PASSWORD = 'repl';
> SHOW SLAVE STATUS\G
```

4. stop and restart replica

```sh
$ docker-compose stop replica
$ : activate `read_only` and `super_read_only` in ./replication-replica.cnf
$ docker-compose start replica
```

5. test

Create test database and test table

```sh
$ docker-compose exec primary mysql -uroot -pprimary-pw
CREATE DATABASE sample_db;
USE sample_db;
CREATE TABLE sample_table; (
  id INTEGER PRIMARY KEY,
  name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
INSERT INTO sample_table (id, name) VALUES
  (1, 'one'),
  (2, 'two'),
  (3, 'three') ;
```

# reference

- エキスパートのためのMySQL運用・管理 トラブルシューティングガイド
- https://qiita.com/wf-yamaday/items/47434b8312737da25521
