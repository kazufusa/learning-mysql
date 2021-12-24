# Change Prompt

## start mysql server

```sh
$ docker run --rm --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:latest
```

## connect from local cli with my prompt

```sh
$ cat ./my.conf
[mysql]

prompt = '\\u@\\h\\_(\\R:\\m:\\s)\\_{\\d}>\\_'

$ mysql --defaults-file=./my.conf -uroot -p --protocol tcp
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.27 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

root@localhost (22:56:13) {(none)}>
```

or I can provide promppt settings as commandline argument.

```sh
$ mysql --defaults-file=./my.conf -uroot -p --protocol tcp --prompt='\u@\h\_(\R:\m:\s)\_{\d}>\_'
...
root@localhost (23:07:26) {(none)}> 
```

## some excape sequencess

|escape sequence|detail|
|--|--|
|\\u|username|
|\\h|hostname of database|
|\\R|year|
|\\m|minute|
|\\s|seconds|
|\\s|database name|
|\\_|space|
