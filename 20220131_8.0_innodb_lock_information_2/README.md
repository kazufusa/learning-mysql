# InnoDB Lock and Lock-wait information (MySQL 8.0), 2

`select ... for share`をしたときのlockを確認する.

## preparements

```sh
$ docker run --rm -w /app -v ${PWD}:/app --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -v ${PWD}:/work -w /work -d mysql:8.0
```

```sql
mysql> \. create_table.sql
Query OK, 0 rows affected, 4 warnings (0.03 sec)

Query OK, 9 rows affected (0.01 sec)
Records: 9  Duplicates: 0  Warnings: 0

mysql> SHOW CREATE TABLE database.lock_test\G
*************************** 1. row ***************************
       Table: lock_test
Create Table: CREATE TABLE `lock_test` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `val1` int NOT NULL,
  `val2` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_val1` (`val1`),
  KEY `idx_val2` (`val2`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3
1 row in set (0.01 sec)

mysql> select * from database.lock_test;
+----+------+------+
| id | val1 | val2 |
+----+------+------+
|  1 |    1 |    6 |
|  2 |    3 |    2 |
|  3 |    6 |    3 |
|  4 |    4 |    1 |
|  5 |    5 |    6 |
|  6 |    2 |    1 |
|  7 |    3 |    3 |
|  8 |    7 |    2 |
|  9 |    8 |    4 |
+----+------+------+
9 rows in set (0.00 sec)

```

## Select for share in Transaction 1

transaction 1内で`select ... for share`したときのロックを見ると
(`select * from performance_schema.data_locks\G`),
tableロックが1つ, recordロックが5つある.

record5つは, id:6,7,8,9と, `supremum pseudo-record`である.
後者はid:9より後のidに対するロック.

```sql
mysql> set autocommit=0;
Query OK, 0 rows affected (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from database.lock_test where id >= 6 for share;
+----+------+------+
| id | val1 | val2 |
+----+------+------+
|  6 |    2 |    1 |
|  7 |    3 |    3 |
|  8 |    7 |    2 |
|  9 |    8 |    4 |
+----+------+------+
4 rows in set (0.00 sec)

mysql> select * from performance_schema.data_locks\G
*************************** 1. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139883583597784:1067:139883595245856
ENGINE_TRANSACTION_ID: 421358560308440
            THREAD_ID: 47
             EVENT_ID: 25
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: NULL
OBJECT_INSTANCE_BEGIN: 139883595245856
            LOCK_TYPE: TABLE
            LOCK_MODE: IS
          LOCK_STATUS: GRANTED
            LOCK_DATA: NULL
*************************** 2. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139883583597784:2:4:7:139883595242864
ENGINE_TRANSACTION_ID: 421358560308440
            THREAD_ID: 47
             EVENT_ID: 25
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139883595242864
            LOCK_TYPE: RECORD
            LOCK_MODE: S,REC_NOT_GAP
          LOCK_STATUS: GRANTED
            LOCK_DATA: 6
*************************** 3. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139883583597784:2:4:1:139883595243208
ENGINE_TRANSACTION_ID: 421358560308440
            THREAD_ID: 47
             EVENT_ID: 25
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139883595243208
            LOCK_TYPE: RECORD
            LOCK_MODE: S
          LOCK_STATUS: GRANTED
            LOCK_DATA: supremum pseudo-record
*************************** 4. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139883583597784:2:4:8:139883595243208
ENGINE_TRANSACTION_ID: 421358560308440
            THREAD_ID: 47
             EVENT_ID: 25
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139883595243208
            LOCK_TYPE: RECORD
            LOCK_MODE: S
          LOCK_STATUS: GRANTED
            LOCK_DATA: 7
*************************** 5. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139883583597784:2:4:9:139883595243208
ENGINE_TRANSACTION_ID: 421358560308440
            THREAD_ID: 47
             EVENT_ID: 25
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139883595243208
            LOCK_TYPE: RECORD
            LOCK_MODE: S
          LOCK_STATUS: GRANTED
            LOCK_DATA: 8
*************************** 6. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139883583597784:2:4:10:139883595243208
ENGINE_TRANSACTION_ID: 421358560308440
            THREAD_ID: 47
             EVENT_ID: 25
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139883595243208
            LOCK_TYPE: RECORD
            LOCK_MODE: S
          LOCK_STATUS: GRANTED
            LOCK_DATA: 9
6 rows in set (0.00 sec)

```

## Try to insert a record in Transaction 2

`supremum pseudo-record`がロックされているので, transaction2でinsertはできない.

New record insertion in transaction 2 waits until finishing transaction1 because `supremum pseudo-record` is locked by transaction 1.

```sql
mysql> set autocommit=0;
Query OK, 0 rows affected (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into lock_test (val1, val2) values (11,12);
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
```
