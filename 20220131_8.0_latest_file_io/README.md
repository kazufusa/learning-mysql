# I/O Monitoring(MySQL 8.0)

## preparements

```sh
$ docker run --rm --cap-add=SYS_PTRACE --security-opt="seccomp=unconfined" --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -d mysql:8.0
```

```sh
# apt update -qq && apt install -y procps strace
```

<!-- # strace -tt -p 1 -->
<!-- # strace -tt -p 1 -e trace=file,close,write -o /tmp/strace.log -->
<!-- # strace -f -p {{ pid }} -o /tmp/strace.log -->

```sql
mysql> CREATE TABLE lock_test (
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  val1 int(11) NOT NULL,
  val2 int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_val1 (val1),
  KEY idx_val2 (val2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

mysql> insert into lock_test (val1, val2) values (1, 6);
```
