# mysql_config_editor

- https://gihyo.jp/dev/serial/01/mysql-road-construction-news/0057
- https://blog.s-style.co.jp/2019/10/5266/

## How to Use mysql_config_editor

```sh
$ docker run --rm --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -d mysql:8.0
```

```sh
$ docker exec -it some-mysql bash
root@8a614062086a:/# mysql_config_editor set --login-path=local --host=localhost --user=root --password
Enter password:
root@8a614062086a:/# cat ~^C
root@8a614062086a:/# ls -a ~
.  ..  .bashrc  .mylogin.cnf  .profile  .wget-hsts
root@8a614062086a:/# cat ~/.mylogin.cnf


Ctܵ]WMa)e 7*BtE[zyhf(' IuRTLdsHTBroot@8a614062086a:/#
```

```sh
root@8a614062086a:/# mysql_config_editor print --all
[local]
user = "root"
password = *****
host = "localhost"
root@8a614062086a:/# mysql_config_editor print --login-path=local
[local]
user = "root"
password = *****
host = "localhost"
root@8a614062086a:/# mysql --login-path=local
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
