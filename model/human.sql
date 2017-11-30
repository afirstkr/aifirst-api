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

_id                 VARCHAR(100)  NOT NULL,
  _name               VARCHAR(100)  DEFAULT NULL,
  _password           VARCHAR(100)  DEFAULT NULL,
  _body               JSON          DEFAULT NULL,
  _createdAt          DATETIME      DEFAULT CURRENT_TIMESTAMP,
  _updatedAt          DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

insert into _channel (_name,_body) values ('이강훈', '{}');
insert into _channel (_name,_body) values ('김현철', '{}');
insert into _channel (_name,_body) values ('강필성', '{}');
insert into _channel (_name,_body) values ('김병훈', '{}');
insert into _channel (_name,_body) values ('권영준', '{}');
insert into _channel (_name,_body) values ('최정한', '{}');
insert into _channel (_name,_body) values ('김세현', '{}');
insert into _channel (_name,_body) values ('이상진', '{}');
insert into _channel (_name,_body) values ('박동철', '{}');
insert into _channel (_name,_body) values ('김대수', '{}');
insert into _channel (_name,_body) values ('문아라', '{}');
insert into _channel (_name,_body) values ('박은정', '{}');
insert into _channel (_name,_body) values ('이재현', '{}');
insert into _channel (_name,_body) values ('정우식', '{}');
insert into _channel (_name,_body) values ('박철', '{}');

insert into _channel (_name,_body) values ('회원관리봇', '{}');
insert into _channel (_name,_body) values ('박철', '{}');

-- only test
-- SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'aifirst';
