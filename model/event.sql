
CREATE TABLE _event (
  _id                 BIGINT        NOT NULL AUTO_INCREMENT,
  _class              VARCHAR(100)  DEFAULT NULL,
  _from               JSON          DEFAULT NULL,
  _to                 JSON          DEFAULT NULL,
  _body               JSON          DEFAULT NULL,
  _date               DATETIME      DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY         (_id),
  KEY                 (_date)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
