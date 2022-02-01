# I/O Monitoring(MySQL 8.0)

## preparements

```sh
$ docker run -it --rm -w /app -v ${PWD}:/app --entrypoint "" --cap-add=ALL --security-opt="seccomp=unconfined" --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -d mysql:8.0 bash
```

```sh
$ docker exec -it some-mysql bash
# apt update -qq && apt install -y procps strace
# strace -t -f -o ./strace.out docker-entrypoint.sh mysqld
```

<!-- # strace -s2048 -f -o ./strace.out docker-entrypoint.sh mysqld -->
<!-- # strace -tt -f -e trace=file,open,close,write -p 1 -->
<!-- # strace -tt -p 1 -->
<!-- # strace -tt -p 1 -e trace=file,close,write -o /tmp/strace.log -->
<!-- # strace -f -p {{ pid }} -o /tmp/strace.log -->

```sql
$ docker exec -it some-mysql mysql -uroot -pmy-secret-pw -D database
mysql> CREATE TABLE test (
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  val1 int(11) NOT NULL,
  val2 int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_val1 (val1),
  KEY idx_val2 (val2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

```sh
```


```sql
mysql> insert into test (val1, val2) values (1, 6);
```

```sql
```
