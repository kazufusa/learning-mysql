# SQL実践入門 04 集約とカット

## preparation

Start mysql with docker,

```sh
$ docker container run --rm --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=database -d mysql:8.0
```

and connect to mysql.

```sh
$ mysql -uroot -pmy-secret-pw --protocol tcp -D database
```

## Non-Aggregated Table

```sql
mysql> create table NonAggTbl (
  id        varchar(32) not null,
  data_type char(1) not null,
  data1     integer,
  data2     integer,
  data3     integer,
  data4     integer,
  data5     integer,
  data6     integer,
  PRIMARY KEY(id, data_type)
) ENGINE=InnoDB CHARSET=utf8mb4;
mysql> INSERT INTO NonAggTbl VALUES
  ('Jim',    'A',  100,  10,     34,  346,   54,  NULL),
  ('Jim',    'B',  45,    2,    167,   77,   90,   157),
  ('Jim',    'C',  NULL,  3,    687, 1355,  324,   457),
  ('Ken',    'A',  78,    5,    724,  457, NULL,     1),
  ('Ken',    'B',  123,  12,    178,  346,   85,   235),
  ('Ken',    'C',  45, NULL,     23,   46,  687,    33),
  ('Beth',   'A',  75,    0,    190,   25,  356,  NULL),
  ('Beth',   'B',  435,   0,    183, NULL,    4,   325),
  ('Beth',   'C',  96,  128,   NULL,    0,    0,    12)
;
mysql> select * from NonAggTbl;
+------+-----------+-------+-------+-------+-------+-------+-------+
| id   | data_type | data1 | data2 | data3 | data4 | data5 | data6 |
+------+-----------+-------+-------+-------+-------+-------+-------+
| Beth | A         |    75 |     0 |   190 |    25 |   356 |  NULL |
| Beth | B         |   435 |     0 |   183 |  NULL |     4 |   325 |
| Beth | C         |    96 |   128 |  NULL |     0 |     0 |    12 |
| Jim  | A         |   100 |    10 |    34 |   346 |    54 |  NULL |
| Jim  | B         |    45 |     2 |   167 |    77 |    90 |   157 |
| Jim  | C         |  NULL |     3 |   687 |  1355 |   324 |   457 |
| Ken  | A         |    78 |     5 |   724 |   457 |  NULL |     1 |
| Ken  | B         |   123 |    12 |   178 |   346 |    85 |   235 |
| Ken  | C         |    45 |  NULL |    23 |    46 |   687 |    33 |
+------+-----------+-------+-------+-------+-------+-------+-------+
9 rows in set (0.00 sec)

mysql> select
  id,
  max(case when data_type = 'A' then data1 else NULL end) as data1,
  max(case when data_type = 'A' then data2 else NULL end) as data2,
  max(case when data_type = 'B' then data3 else NULL end) as data3,
  max(case when data_type = 'B' then data4 else NULL end) as data4,
  max(case when data_type = 'B' then data5 else NULL end) as data5,
  max(case when data_type = 'c' then data6 else NULL end) as data6
from NonAggTbl
group by id;
+------+-------+-------+-------+-------+-------+-------+
| id   | data1 | data2 | data3 | data4 | data5 | data6 |
+------+-------+-------+-------+-------+-------+-------+
| Beth |    75 |     0 |   183 |  NULL |     4 |    12 |
| Jim  |   100 |    10 |   167 |    77 |    90 |   457 |
| Ken  |    78 |     5 |   178 |   346 |    85 |    33 |
+------+-------+-------+-------+-------+-------+-------+
3 rows in set (0.00 sec)

mysql> explain select
  id,
  max(case when data_type = 'A' then data1 else NULL end) as data1,
  max(case when data_type = 'A' then data2 else NULL end) as data2,
  max(case when data_type = 'B' then data3 else NULL end) as data3,
  max(case when data_type = 'B' then data4 else NULL end) as data4,
  max(case when data_type = 'B' then data5 else NULL end) as data5,
  max(case when data_type = 'c' then data6 else NULL end) as data6
from NonAggTbl
group by id\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: NonAggTbl
   partitions: NULL
         type: index
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 134
          ref: NULL
         rows: 9
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.00 sec)

```

## PriceByAge

```
mysql> create table PriceByAge (
  product_id varchar(32) not null,
  low_age    integer not null,
  high_age   integer not null,
  price      integer not null,
  PRIMARY KEY (product_id, low_age),
  CHECK (low_age < high_age)
);
mysql> insert into PriceByAge values
  ('製品1', 0  , 50  , 2000),
  ('製品1', 51 , 100 , 3000),
  ('製品2', 0  , 100 , 4200),
  ('製品3', 0  , 20  , 500),
  ('製品3', 31 , 70  , 800),
  ('製品3', 71 , 100 , 1000),
  ('製品4', 0  , 99  , 8900)
;
mysql> select * from PriceByAge;
+------------+---------+----------+-------+
| product_id | low_age | high_age | price |
+------------+---------+----------+-------+
| 製品1      |       0 |       50 |  2000 |
| 製品1      |      51 |      100 |  3000 |
| 製品2      |       0 |      100 |  4200 |
| 製品3      |       0 |       20 |   500 |
| 製品3      |      31 |       70 |   800 |
| 製品3      |      71 |      100 |  1000 |
| 製品4      |       0 |       99 |  8900 |
+------------+---------+----------+-------+
7 rows in set (0.00 sec)

mysql> select
  product_id
from PriceByAge
group by product_id
having sum(high_age - low_age + 1) = 101
;
+------------+
| product_id |
+------------+
| 製品1      |
| 製品2      |
+------------+
2 rows in set (0.00 sec)

```

## Cut and Partition

```sql
mysql> create table Persons (
  name varchar(8) not null,
  age integer not null,
  height float not null,
  weight float not null,
  primary key (name)
)
;

mysql> insert into Persons values
  ('Anderson', 30, 188, 90),
  ('Adela',    21, 167, 55),
  ('Bates',    87, 158, 48),
  ('Becky',    54, 187, 70),
  ('Bill',     39, 177, 120),
  ('Chris',    90, 175, 48),
  ('Darwin',   12, 160, 55),
  ('Dawson',   25, 182, 90),
  ('Donald',   30, 176, 53)
;

mysql> select * from Persons;
+----------+-----+--------+--------+
| name     | age | height | weight |
+----------+-----+--------+--------+
| Adela    |  21 |    167 |     55 |
| Anderson |  30 |    188 |     90 |
| Bates    |  87 |    158 |     48 |
| Becky    |  54 |    187 |     70 |
| Bill     |  39 |    177 |    120 |
| Chris    |  90 |    175 |     48 |
| Darwin   |  12 |    160 |     55 |
| Dawson   |  25 |    182 |     90 |
| Donald   |  30 |    176 |     53 |
+----------+-----+--------+--------+
9 rows in set (0.00 sec)

mysql> select
  substring(name, 1, 1) as initial,
  count(*) as n
from Persons
group by substring(name, 1, 1)
;
+---------+---+
| initial | n |
+---------+---+
| A       | 2 |
| B       | 3 |
| C       | 1 |
| D       | 3 |
+---------+---+
4 rows in set (0.00 sec)

mysql> select
  substring(name, 1, 1) as initial,
  count(*) as n
from Persons
group by initial
;
+---------+---+
| initial | n |
+---------+---+
| A       | 2 |
| B       | 3 |
| C       | 1 |
| D       | 3 |
+---------+---+
4 rows in set (0.00 sec)

mysql> explain select
  substring(name, 1, 1) as initial,
  count(*) as n
from Persons
group by initial
\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: Persons
   partitions: NULL
         type: index
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 34
          ref: NULL
         rows: 9
     filtered: 100.00
        Extra: Using index; Using temporary
1 row in set, 1 warning (0.00 sec)

mysql> select
  case
    when age < 20 then '子供'
    when age between 20 and 69 then '成人'
    else '老人'
  end as age_class,
  count(*)
from Persons
group by age_class
;
+-----------+----------+
| age_class | count(*) |
+-----------+----------+
| 成人      |        6 |
| 老人      |        2 |
| 子供      |        1 |
+-----------+----------+
3 rows in set (0.00 sec)


mysql> explain select
  case
    when age < 20 then '子供'
    when age between 20 and 69 then '成人'
    else '老人'
  end as age_class,
  count(*)
from Persons
group by age_class
\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: Persons
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 9
     filtered: 100.00
        Extra: Using temporary
1 row in set, 1 warning (0.00 sec)

select
  name,
  age,
  case
    when age < 20 then '子供'
    when age between 20 and 69 then '成人'
    else '老人'
  end as age_class,
  rank() over(partition by 
    case
      when age < 20 then '子供'
      when age between 20 and 69 then '成人'
      else '老人'
    end
  order by age) as age_rank_in_class
from Persons
;
+----------+-----+-----------+-------------------+
| name     | age | age_class | age_rank_in_class |
+----------+-----+-----------+-------------------+
| Darwin   |  12 | 子供      |                 1 |
| Adela    |  21 | 成人      |                 1 |
| Dawson   |  25 | 成人      |                 2 |
| Anderson |  30 | 成人      |                 3 |
| Donald   |  30 | 成人      |                 3 |
| Bill     |  39 | 成人      |                 5 |
| Becky    |  54 | 成人      |                 6 |
| Bates    |  87 | 老人      |                 1 |
| Chris    |  90 | 老人      |                 2 |
+----------+-----+-----------+-------------------+
9 rows in set (0.00 sec)

```
