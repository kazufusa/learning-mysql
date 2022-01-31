# InnoDB Lock and Lock-wait information (MySQL 8.0)

- ref: https://qiita.com/hmatsu47/items/607d176e885f098262e8

## preparements

```sh
$ docker run --rm --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -v ${PWD}:/work -w /work -d mysql:8.0
```

```sql
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

## update in transaction 1

```sql
mysql> set autocommit=0;
Query OK, 0 rows affected (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> update database.lock_test set val1=9 where id=6;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

```

## show lock information

```sql
mysql> select * from sys.innodb_lock_waits\G
Empty set (0.04 sec)
```


## Update in transaction 2

Open second terminal, login MySQL, and begin new transaction(2).

```sql
mysql> set autocommit=0;
Query OK, 0 rows affected (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> update database.lock_test set val1=6 where id=6;
```

Transaction2 is waiting.

```sql
mysql> select * from sys.innodb_lock_waits\G
*************************** 1. row ***************************
                wait_started: 2022-01-31 05:33:21
                    wait_age: 00:00:03
               wait_age_secs: 3
                locked_table: `database`.`lock_test`
         locked_table_schema: database
           locked_table_name: lock_test
      locked_table_partition: NULL
   locked_table_subpartition: NULL
                locked_index: PRIMARY
                 locked_type: RECORD
              waiting_trx_id: 1866
         waiting_trx_started: 2022-01-31 05:30:13
             waiting_trx_age: 00:03:11
     waiting_trx_rows_locked: 3
   waiting_trx_rows_modified: 0
                 waiting_pid: 11
               waiting_query: update database.lock_test set val1=6 where id=6
             waiting_lock_id: 139998749786112:4:4:7:139998754060352
           waiting_lock_mode: X,REC_NOT_GAP
             blocking_trx_id: 1864
                blocking_pid: 10
              blocking_query: select * from sys.innodb_lock_waits
            blocking_lock_id: 139998749785304:4:4:7:139998754053488
          blocking_lock_mode: X,REC_NOT_GAP
        blocking_trx_started: 2022-01-31 05:24:53
            blocking_trx_age: 00:08:31
    blocking_trx_rows_locked: 1
  blocking_trx_rows_modified: 1
     sql_kill_blocking_query: KILL QUERY 10
sql_kill_blocking_connection: KILL 10
1 row in set (0.00 sec)

mysql> select * from performance_schema.data_locks\G
*************************** 1. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139998749786112:1069:139998754062576
ENGINE_TRANSACTION_ID: 1866
            THREAD_ID: 50
             EVENT_ID: 12
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: NULL
OBJECT_INSTANCE_BEGIN: 139998754062576
            LOCK_TYPE: TABLE
            LOCK_MODE: IX
          LOCK_STATUS: GRANTED
            LOCK_DATA: NULL
*************************** 2. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139998749786112:4:4:7:139998754060008
ENGINE_TRANSACTION_ID: 1866
            THREAD_ID: 50
             EVENT_ID: 13
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139998754060008
            LOCK_TYPE: RECORD
            LOCK_MODE: X,REC_NOT_GAP
          LOCK_STATUS: WAITING
            LOCK_DATA: 6
*************************** 3. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139998749785304:1069:139998754056480
ENGINE_TRANSACTION_ID: 1864
            THREAD_ID: 49
             EVENT_ID: 31
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: NULL
OBJECT_INSTANCE_BEGIN: 139998754056480
            LOCK_TYPE: TABLE
            LOCK_MODE: IX
          LOCK_STATUS: GRANTED
            LOCK_DATA: NULL
*************************** 4. row ***************************
               ENGINE: INNODB
       ENGINE_LOCK_ID: 139998749785304:4:4:7:139998754053488
ENGINE_TRANSACTION_ID: 1864
            THREAD_ID: 49
             EVENT_ID: 31
        OBJECT_SCHEMA: database
          OBJECT_NAME: lock_test
       PARTITION_NAME: NULL
    SUBPARTITION_NAME: NULL
           INDEX_NAME: PRIMARY
OBJECT_INSTANCE_BEGIN: 139998754053488
            LOCK_TYPE: RECORD
            LOCK_MODE: X,REC_NOT_GAP
          LOCK_STATUS: GRANTED
            LOCK_DATA: 6
4 rows in set (0.01 sec)

mysql> select * from performance_schema.data_lock_waits\G
*************************** 1. row ***************************
                          ENGINE: INNODB
       REQUESTING_ENGINE_LOCK_ID: 139998749786112:4:4:7:139998754060696
REQUESTING_ENGINE_TRANSACTION_ID: 1866
            REQUESTING_THREAD_ID: 50
             REQUESTING_EVENT_ID: 15
REQUESTING_OBJECT_INSTANCE_BEGIN: 139998754060696
         BLOCKING_ENGINE_LOCK_ID: 139998749785304:4:4:7:139998754053488
  BLOCKING_ENGINE_TRANSACTION_ID: 1864
              BLOCKING_THREAD_ID: 49
               BLOCKING_EVENT_ID: 31
  BLOCKING_OBJECT_INSTANCE_BEGIN: 139998754053488
1 row in set (0.00 sec)

```
