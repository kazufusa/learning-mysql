# Replication

## 1. Docker起動

```sh
$ docker-compose up -d --remove-orphans
```

## 2. primaryサーバにreplication用ユーザを追加

```sh
$ docker-compose exec primary hostname -i
172.23.0.2
$ docker-compose exec primary mysql -uroot -pprimary-pw
> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.23.0.%' IDENTIFIED BY 'repl';
Query OK, 0 rows affected, 1 warning (0.01 sec)

> SELECT user,host FROM mysql.user;
+---------------+------------+
| user          | host       |
+---------------+------------+
| root          | %          |
| repl          | 172.23.0.% |
| mysql.session | localhost  |
| mysql.sys     | localhost  |
| root          | localhost  |
+---------------+------------+
5 rows in set (0.00 sec)

> SHOW GRANTS FOR 'repl'@'172.23.0.%';
+-------------------------------------------------------+
| Grants for repl@172.23.0.%                            |
+-------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.23.0.%' |
+-------------------------------------------------------+
1 row in set (0.00 sec)

> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: ON.000003
         Position: 486
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: 0259f3e4-6d68-11ec-b742-0242ac1b0003:1-6
1 row in set (0.00 sec)
```

## 3. replicaサーバにreplicationを設定

```sh
$ docker-compose exec replica mysql -uroot -preplica-pw
> CHANGE MASTER TO
    ->   MASTER_HOST='mysql-primary',
    ->   MASTER_PORT=3306,
    ->   MASTER_LOG_FILE='ON.000003',
    ->   MASTER_LOG_POS=486;
Query OK, 0 rows affected (0.05 sec)

> START SLAVE USER = 'repl' PASSWORD = 'repl';
Query OK, 0 rows affected, 1 warning (0.01 sec)

> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: mysql-primary
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: ON.000003
          Read_Master_Log_Pos: 486
               Relay_Log_File: mysql-replica-relay-bin.000002
                Relay_Log_Pos: 313
        Relay_Master_Log_File: ON.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 486
              Relay_Log_Space: 528
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: a1a35959-6d6a-11ec-96e2-0242ac170002
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set: a1a04c49-6d6a-11ec-9a01-0242ac170003:1-5
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
1 row in set (0.00 sec)

```

## 4. replicationサーバでupdate DMLを禁止

```sh
$ docker-compose stop replica
$ : activate `read_only` and `super_read_only` in ./replication-replica.cnf
$ docker-compose start replica
```

## 5. 動作確認

### 5.1. primaryにデータベース, テーブル, レコードを追加

```sh
$ docker-compose exec primary mysql -uroot -pprimary-pw
> CREATE DATABASE sample_db;
> USE sample_db;
> CREATE TABLE sample_table ( id INT PRIMARY KEY, name VARCHAR(100) NOT NULL) ENGINE=InnoDB;
> INSERT INTO sample_table (id, name) VALUES
  (1, 'one'),
  (2, 'two'),
  (3, 'three');
```

### 5.2. replicaで追加されたデータベース, テーブル, レコードを確認

```sh
$ docker-compose exec replica mysql -uroot -preplica-pw
> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sample_db          |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

> USE sample_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
> SHOW TABLES;
+---------------------+
| Tables_in_sample_db |
+---------------------+
| sample_table        |
+---------------------+
1 row in set (0.00 sec)

> SELECT * FROM sample_table;
+----+-------+
| id | name  |
+----+-------+
|  1 | one   |
|  2 | two   |
|  3 | three |
+----+-------+
3 rows in set (0.00 sec)
```

# TIPS

## MySQLで権限付きユーザを作成する

```sql
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.23.0.%' IDENTIFIED BY 'repl';
```

## FLUSH PRIVILEGEが必要な場合とは

https://dev.mysql.com/doc/refman/5.7/en/privilege-changes.html

`mysql.user`を直接操作する場合に必要な様子. 今回は不要.

## DockerでIPセグメントを設定する

https://docs.docker.com/compose/compose-file/compose-file-v3/#ipam

```yml
networks:
  demo-network:
    ipam:
      driver: default
      config:
        - subnet: 172.23.0.0/16
```

# reference

- エキスパートのためのMySQL運用・管理 トラブルシューティングガイド
- https://qiita.com/wf-yamaday/items/47434b8312737da25521
