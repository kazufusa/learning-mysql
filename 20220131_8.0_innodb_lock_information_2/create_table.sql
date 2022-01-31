CREATE TABLE lock_test (
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  val1 int(11) NOT NULL,
  val2 int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_val1 (val1),
  KEY idx_val2 (val2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into lock_test (val1, val2) values
  (1, 6),
  (3, 2),
  (6, 3),
  (4, 1),
  (5, 6),
  (2, 1),
  (3, 3),
  (7, 2),
  (8, 4)
;
