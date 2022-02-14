# SQL実践入門 05 ループ 手続き型の呪縛

## preparation

Start mysql with docker,

```sh
$ docker container run --rm --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -d mysql:8.0
```

and connect to mysql.

```sh
$ mysql -uroot -pmy-secret-pw --protocol tcp -D database
```

## 1. Sales

```sql
mysql> create table Sales (
  company varchar(1) not null,
  year    integer not null,
  sale    integer not null,
  primary key (company, year)
) ;

mysql> insert into Sales values
  ('A', 2002, 50),
  ('A', 2003, 52),
  ('A', 2004, 55),
  ('A', 2007, 55),

  ('B', 2001, 27),
  ('B', 2005, 28),
  ('B', 2006, 28),
  ('B', 2009, 30),

  ('C', 2001, 40),
  ('C', 2005, 39),
  ('C', 2006, 38),
  ('C', 2010, 35)
;

mysql> select * from Sales;
+---------+------+------+
| company | year | sale |
+---------+------+------+
| A       | 2002 |   50 |
| A       | 2003 |   52 |
| A       | 2004 |   55 |
| A       | 2007 |   55 |
| B       | 2001 |   27 |
| B       | 2005 |   28 |
| B       | 2006 |   28 |
| B       | 2009 |   30 |
| C       | 2001 |   40 |
| C       | 2005 |   39 |
| C       | 2006 |   38 |
| C       | 2010 |   35 |
+---------+------+------+
12 rows in set (0.01 sec)

mysql> select
  company,
  year,
  sale,
  case
    sign(sale - max(sale) over (
      partition by company
      order by year
      rows between 1 preceding and 1 preceding
    ))
    when 1 then '+'
    when 0 then '='
    when -1 then '-1'
    else NULL
  end as var
from
  Sales
;
+---------+------+------+------+
| company | year | sale | var  |
+---------+------+------+------+
| A       | 2002 |   50 | NULL |
| A       | 2003 |   52 | +    |
| A       | 2004 |   55 | +    |
| A       | 2007 |   55 | =    |
| B       | 2001 |   27 | NULL |
| B       | 2005 |   28 | +    |
| B       | 2006 |   28 | =    |
| B       | 2009 |   30 | +    |
| C       | 2001 |   40 | NULL |
| C       | 2005 |   39 | -1   |
| C       | 2006 |   38 | -1   |
| C       | 2010 |   35 | -1   |
+---------+------+------+------+
12 rows in set (0.00 sec)

mysql> explain select
  company,
  year,
  sale,
  case
    sign(sale - max(sale) over (
      partition by company
      order by year
      rows between 1 preceding and 1 preceding
    ))
    when 1 then '+'
    when 0 then '='
    when -1 then '-1'
    else NULL
  end as var
from
  Sales
\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: Sales
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12
     filtered: 100.00
        Extra: Using filesort
1 row in set, 2 warnings (0.00 sec)

mysql> create table PostalCode (
  pcode varchar(7),
  distinct_name varchar(256),
  CONSTRAINT pk_pcode PRIMARY KEY (pcode)
) ENGINE=InnoDB CHARSET=utf8mb4;

mysql> INSERT INTO PostalCode VALUES
  ('4130001',  '静岡県熱海市泉'),
  ('4130002',  '静岡県熱海市伊豆山'),
  ('4130103',  '静岡県熱海市網代'),
  ('4130041',  '静岡県熱海市青葉町'),
  ('4103213',  '静岡県伊豆市青羽根'),
  ('4380824',  '静岡県磐田市赤池')
;

mysql> select * from PostalCode;
+---------+-----------------------------+
| pcode   | distinct_name               |
+---------+-----------------------------+
| 4103213 | 静岡県伊豆市青羽根          |
| 4130001 | 静岡県熱海市泉              |
| 4130002 | 静岡県熱海市伊豆山          |
| 4130041 | 静岡県熱海市青葉町          |
| 4130103 | 静岡県熱海市網代            |
| 4380824 | 静岡県磐田市赤池            |
+---------+-----------------------------+
6 rows in set (0.00 sec)

-- find pcode near by 4130033
mysql> select
  rt.pcode
from (
  select
    pcode,
    Rank() over (order by
      case
        when pcode = '4130033' then 0
        when pcode like '413003%'  then 1
        when pcode like '41300%'   then 2
        when pcode like '4130%'    then 3
        when pcode like '413%'     then 4
        when pcode like '41%'      then 5
        when pcode like '4%'       then 6
        else 7
      end
    ) as rnk
  from PostalCode
  ) as rt
where rnk = 1
;
+---------+
| pcode   |
+---------+
| 4130001 |
| 4130002 |
| 4130041 |
+---------+
3 rows in set (0.00 sec)

mysql> exlpain select
  rt.pcode
from (
  select
    pcode,
    Rank() over (order by
      case
        when pcode = '4130033' then 0
        when pcode like '413003%'  then 1
        when pcode like '41300%'   then 2
        when pcode like '4130%'    then 3
        when pcode like '413%'     then 4
        when pcode like '41%'      then 5
        when pcode like '4%'       then 6
        else 7
      end
    ) as rnk
  from PostalCode
  ) as rt
where rnk = 1
\G
*************************** 1. row ***************************
           id: 1
  select_type: PRIMARY
        table: <derived2>
   partitions: NULL
         type: ref
possible_keys: <auto_key0>
          key: <auto_key0>
      key_len: 8
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 2. row ***************************
           id: 2
  select_type: DERIVED
        table: PostalCode
   partitions: NULL
         type: index
possible_keys: NULL
          key: PRIMARY
      key_len: 30
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: Using index; Using filesort
2 rows in set, 2 warnings (0.00 sec)

mysql> select
  pcode
from PostalCode
where
  case
    when pcode = '4130033' then 0
    when pcode like '413003%'  then 1
    when pcode like '41300%'   then 2
    when pcode like '4130%'    then 3
    when pcode like '413%'     then 4
    when pcode like '41%'      then 5
    when pcode like '4%'       then 6
    else 7
  end = (
    select min(
      case
        when pcode = '4130033' then 0
        when pcode like '413003%'  then 1
        when pcode like '41300%'   then 2
        when pcode like '4130%'    then 3
        when pcode like '413%'     then 4
        when pcode like '41%'      then 5
        when pcode like '4%'       then 6
        else 7
      end
    ) from PostalCode
  )
;
+---------+
| pcode   |
+---------+
| 4130001 |
| 4130002 |
| 4130041 |
+---------+
3 rows in set (0.00 sec)

mysql> explain select
  pcode
from PostalCode
where
  case
    when pcode = '4130033' then 0
    when pcode like '413003%'  then 1
    when pcode like '41300%'   then 2
    when pcode like '4130%'    then 3
    when pcode like '413%'     then 4
    when pcode like '41%'      then 5
    when pcode like '4%'       then 6
    else 7
  end = (
    select min(
      case
        when pcode = '4130033' then 0
        when pcode like '413003%'  then 1
        when pcode like '41300%'   then 2
        when pcode like '4130%'    then 3
        when pcode like '413%'     then 4
        when pcode like '41%'      then 5
        when pcode like '4%'       then 6
        else 7
      end
    ) from PostalCode
  )
;
*************************** 1. row ***************************
           id: 1
  select_type: PRIMARY
        table: PostalCode
   partitions: NULL
         type: index
possible_keys: NULL
          key: PRIMARY
      key_len: 30
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: Using where; Using index
*************************** 2. row ***************************
           id: 2
  select_type: SUBQUERY
        table: PostalCode
   partitions: NULL
         type: index
possible_keys: NULL
          key: PRIMARY
      key_len: 30
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: Using index
2 rows in set, 1 warning (0.00 sec)

```

## 2. List model

```sql
mysql> create table PostalHistory (
  name char(1),
  pcode char(7),
  new_pcode char(7),
  constraint pk_name_pcode primary key (name, pcode)
);
mysql> create index idx_name_pcode on PostalHistory(new_pcode);
mysql> insert into PostalHistory values
  ('A', '4130001', '4130002'),
  ('A', '4130002', '4130103'),
  ('A', '4130103', NULL     ),
  ('B', '4130041', NULL     ),
  ('C', '4103213', '4380824'),
  ('C', '4380824', NULL     )
;
mysql> select * from PostalHistory;
+------+---------+-----------+
| name | pcode   | new_pcode |
+------+---------+-----------+
| A    | 4130103 | NULL      |
| B    | 4130041 | NULL      |
| C    | 4380824 | NULL      |
| A    | 4130001 | 4130002   |
| A    | 4130002 | 4130103   |
| C    | 4103213 | 4380824   |
+------+---------+-----------+
6 rows in set (0.01 sec)

```
