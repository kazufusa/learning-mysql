create table t1 (a int unsigned not null primary key auto_increment) engine innodb;

insert into t1 values (), (), ();

begin;
  select * from t1 where a >-= 1 lock in share mode;
