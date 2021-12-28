# EXPLAIN and JOIN

## Try EXPLAIN SQL including JOIN

```sql
CREATE TABLE IF NOT EXISTS CountryLanguage
  (
    id          INT NOT NULL PRIMARY KEY,
    name        VARCHAR(256),
    CountryCode INT,
    IsOfficial  CHAR(1)
  )
;

CREATE TABLE IF NOT EXISTS Country
  (
    id      INT NOT NULL PRIMARY KEY,
    name    VARCHAR(256),
    Code    INT,
    Capital INT
  )
;

CREATE TABLE IF NOT EXISTS City
  (
    id   INT NOT NULL PRIMARY KEY,
    name VARCHAR(256)
  )
;

EXPLAIN SELECT * FROM
  CountryLanguage
    JOIN Country ON CountryLanguage.CountryCode = Country.Code
    JOIN City ON Country.Capital = City.ID
WHERE CountryLanguage.IsOfficial = 'T';

DROP TABLE IF EXISTS CountryLanguage, Country, City;
```

```sh
$ : start MySQL server
$ docker run --rm --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -v ${PWD}:/work -w /work -d mysql:latest
$ : wait some seconds
$ : try explain
$ docker exec -it some-mysql mysql -uroot -pmy-secret-pw -D database -e 'source ./explain.sql'
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+-----------------+------------+--------+---------------+---------+---------+--------------------------+------+----------+--------------------------------------------+
| id | select_type | table           | partitions | type   | possible_keys | key     | key_len | ref                      | rows | filtered | Extra                                      |
+----+-------------+-----------------+------------+--------+---------------+---------+---------+--------------------------+------+----------+--------------------------------------------+
|  1 | SIMPLE      | CountryLanguage | NULL       | ALL    | NULL          | NULL    | NULL    | NULL                     |    1 |   100.00 | Using where                                |
|  1 | SIMPLE      | Country         | NULL       | ALL    | NULL          | NULL    | NULL    | NULL                     |    1 |   100.00 | Using where; Using join buffer (hash join) |
|  1 | SIMPLE      | City            | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | database.Country.Capital |    1 |   100.00 | NULL                                       |
+----+-------------+-----------------+------------+--------+---------------+---------+---------+--------------------------+------+----------+--------------------------------------------+
```

1. JOIN sql has same `ID` and same `select_type(=SIMPLE)`
    - SIMPLE means `Nested Loop JOIN` (NLJ)
2. `table` means target table
3. type (access_type) means the join type
    - eq_ref
        - use index in JOIN
        - **the best possible join type**
        - https://dev.mysql.com/doc/refman/8.0/en/explain-output.html#jointype_eq_ref
    - ALL
        - A full table scan is done.
        - usually **very** bad in all other cases.
        - https://dev.mysql.com/doc/refman/8.0/en/explain-output.html#jointype_all
4. possible_keys are the column indicates the indexes from which MySQL can choose to find the rows in this table.
    - https://dev.mysql.com/doc/refman/8.0/en/explain-output.html#explain_possible_keys
5. key is the key that MySQL actually decided to use.
6. key_len indicates the length of the key that MySQL decided to use.
7. ref shows which columns or constants are compared to the index
    - https://dev.mysql.com/doc/refman/8.0/en/explain-output.html#explain_ref
8. rows
9. filtered
    - https://dev.mysql.com/doc/refman/8.0/en/explain-output.html#explain_filtered
10. Extra

## EXPLAINコマンドの使い方

https://nippondanji.blogspot.com/2009/03/mysqlexplain.html

> EXPLAINコマンドの各フィールドの詳細を説明したが、実際にEXPLAINコマンドを使ってクエリの実行計画を見る際には次のようなステップを踏むといいだろう。
> 1.  id/select_type/tableフィールドを見て、どのテーブルがどの順序でアクセスされるのかを知る。これらはクエリの構造を示すフィールドであると言える。サブクエリが含まれている場合にはEXPLAINの表示順とアクセスされる順序が異なる場合があるので気をつける必要がある。
> 2. type/key/ref/rowsフィールドを見て、各テーブルから行がどのようにフェッチされるのかを知る。どのテーブルへのアクセスが最も重いか（クエリの性能の足を引っ張っているのか）を、これらのフィールドから判断することが出来る。
> 3. Extraフィールドを見て、オプティマイザがどのように判断して、各々のテーブルへのアクセスにおいて何を実行しているのかを知る。Extraフィールドはオプティマイザの挙動を示すものであり、クエリの全体像を把握するのに役立つ。

