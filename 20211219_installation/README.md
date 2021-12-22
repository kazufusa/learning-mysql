# Install MySQL

https://dev.mysql.com/doc/refman/8.0/en/binary-installation.html

documentを参考にinstall.shを書いた. 以下の手順でMySQLをバイナリインストールできる.

事前にmysqldバイナリ ./mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz を https://dev.mysql.com/downloads/mysql/ からダウンロードすること.

```sh
$ docker run -v ${PWD}:/app -w /app --rm -it ubuntu bash
root@00000000:/app# sh ./install.sh # 途中でtemporary passwordが表示される
root@00000000:/app# apt-get install -y libtinfo5
root@00000000:/app#  /usr/local/mysql/bin/mysql -pXXXXXXXX
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 17
Server version: 8.0.27

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
