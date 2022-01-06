# InnoDBでPhantom readが起きないことを確認する

MySQL5.7を使用.

```sh
$ docker run --rm --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -v ${PWD}:/work -w /work -d mysql:5.7
```

## Enable InnoDB monitor

```sql
mysql> CREATE TABLE innodb_monitor (a INT) ENGINE INNODB;
```

innodb-status-file=1 ??

https://dev.mysql.com/doc/refman/5.7/en/innodb-enabling-monitors.html

## session 1

```
mysql> create table t1 (a int unsigned not null primary key auto_increment) engine innodb;
mysql> insert into t1 values (), (), ();
Query OK, 3 rows affected (0.02 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> select * from t1;
+---+
| a |
+---+
| 1 |
| 2 |
| 3 |
+---+
3 rows in set (0.01 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from t1;
+---+
| a |
+---+
| 1 |
| 2 |
| 3 |
+---+
3 rows in set (0.00 sec)

mysql> select * from t1;
+---+
| a |
+---+
| 1 |
| 2 |
| 3 |
+---+
3 rows in set (0.01 sec)

mysql> commit;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from t1;
+---+
| a |
+---+
| 1 |
| 2 |
| 3 |
| 4 |
+---+
4 rows in set (0.00 sec)

```

## session 2

```
mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into t1 values ();
Query OK, 1 row affected (0.00 sec)

mysql> commit;
Query OK, 0 rows affected (0.01 sec)
```
