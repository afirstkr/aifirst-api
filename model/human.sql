CREATE TABLE _human (
  _id                 VARCHAR(100)  NOT NULL,
  _class              VARCHAR(100)  DEFAULT NULL,
  _from               JSON          DEFAULT NULL,
  _to                 JSON          DEFAULT NULL,
  _body               JSON          DEFAULT NULL,
  _date               DATETIME      DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY         (_id),
  KEY                 (_date)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- for sequence
CREATE TABLE _sequence (
  _seqName            VARCHAR(100) NOT NULL,
  _seqVal             BIGINT       NOT NULL,

  PRIMARY KEY         (_seqName)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DELIMITER ;;
CREATE FUNCTION _nextSeq()
  RETURNS BIGINT
  MODIFIES SQL DATA
  SQL SECURITY INVOKER
  DETERMINISTIC
BEGIN
  INSERT INTO _sequence
    SET _seqName='DEFAULT', _seqVal=(@v_current_value:=1)
  ON DUPLICATE KEY
    UPDATE _seqVal=(@v_current_value:=_seqVal+1);
  RETURN @v_current_value;
END ;;
DELIMITER ;
--


insert into _channel (_id,_body) values ('이강훈', '{}');

-- only test
-- SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'aifirst';
