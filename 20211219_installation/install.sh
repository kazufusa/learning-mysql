#!/bin/sh

# https://dev.mysql.com/doc/refman/8.0/en/binary-installation.html

set -Ceux

# 事前にmysqldバイナリをダウンロードすること.
# https://dev.mysql.com/downloads/mysql/

workdir=/app

apt-get update && apt-get install -y xz-utils libaio1 libnuma1 openssl
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
cd /usr/local
tar xvf ${workdir}/mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz
ln -s mysql-8.0.27-linux-glibc2.12-x86_64 mysql
cd mysql
mkdir mysql-files
chown mysql:mysql mysql-files
chmod 750 mysql-files
bin/mysqld  --initialize --user=mysql # 途中でtemporary passwordが表示される.
bin/mysql_ssl_rsa_setup
bin/mysqld_safe --user=mysql &
