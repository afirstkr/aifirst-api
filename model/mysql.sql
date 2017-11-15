drop database aifirst;
create database aifirst;
use aifirst;

CREATE TABLE _user (
  _userID             VARCHAR(100)  NOT NULL,
  _password           VARCHAR(100)  DEFAULT NULL,
  _userName           VARCHAR(100)  DEFAULT NULL,
  _mobile             VARCHAR(100)  DEFAULT NULL,
  _birthdate          VARCHAR(100)  DEFAULT NULL,
  _sex                VARCHAR(1)    DEFAULT NULL,
  _class              VARCHAR(100)  DEFAULT NULL,
  _state              VARCHAR(100)  DEFAULT NULL,
  _thumbnailURL       VARCHAR(1000) DEFAULT NULL,
  _isResigned         BOOL          DEFAULT false,
  _memo               LONGTEXT      DEFAULT NULL,
  _createdAt          DATETIME      DEFAULT CURRENT_TIMESTAMP,
  _updatedAt          DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  _deletedAt          DATETIME      DEFAULT NULL,

  PRIMARY KEY         (_userID),
  KEY                 (_userName),
  KEY                 (_mobile),
  KEY                 (_birthdate),
  KEY                 (_sex),
  KEY                 (_class),
  KEY                 (_state),
  KEY                 (_isResigned),
  FULLTEXT KEY        (_memo),
  KEY                 (_createdAt),
  KEY                 (_deletedAt)
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


insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user01','user01','홍길동','01063112616','19751217','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user02','user02','고은서','01099162463','19190412','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user03','user03','허현준','01025336084','19800702','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user04','user04','고민호','01015688716','19210818','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user05','user05','권지민','01073614214','19161020','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user06','user06','송신영','01068362619','19550416','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user07','user07','김성자','01098070524','20141207','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user08','user08','곽민재','01041416685','19520528','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user09','user09','은남선','01091686027','19380720','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user10','user10','현소영','01036618219','19911107','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user11','user11','추영남','01087995846','19190412','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user12','user12','구수진','01012244317','19610624','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user13','user13','두민경','01023306215','19461009','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user14','user14','구승훈','01089496419','19300416','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user15','user15','선정은','01073606814','20120527','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user16','user16','천남선','01097281184','19181217','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user17','user17','송태연','01038008304','20030526','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user18','user18','남필순','01066247126','19960404','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user19','user19','성동준','01027676331','19870116','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user20','user20','방호성','01035526141','19410623','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user21','user21','탁준서','01049157462','19830702','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user22','user22','한태희','01030036773','19870214','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user23','user23','안명희','01037080961','19470923','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user24','user24','돈성숙','01015374781','19540205','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user25','user25','안혜진','01044653388','19270104','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user26','user26','공은정','01088991862','19740328','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user27','user27','허정은','01040839236','19610923','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user28','user28','서은아','01050208353','19400521','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user29','user29','현소영','01036618219','19911107','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user30','user30','태진영','01088113136','19420314','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user31','user31','은창우','01070952299','19650720','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user32','user32','문지민','01024833495','19880913','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user33','user33','학보영','01041400619','19270205','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user34','user34','강은영','01025087350','19940522','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user35','user35','김승민','01025551964','20080309','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user36','user36','손경구','01013133067','20030723','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user37','user37','강동건','01045197803','19690527','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user38','user38','추지은','01072721977','19180313','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user39','user39','설은혜','01040666077','20050507','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user40','user40','도연석','01093110908','19610405','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user41','user41','장태연','01022939113','19940708','F','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user42','user42','민광훈','01099460589','19570322','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user43','user43','고승헌','01054935245','20111017','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user44','user44','박혜림','01043504391','19680624','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user45','user45','허지원','01079676274','20141114','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user46','user46','서승희','01092115090','19190106','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user47','user47','기은영','01053212497','19371126','M','MEMBER');
insert into _user (_userID,_password,_userName,_mobile,_birthdate,_sex,_class) values ('user48','user48','맹성자','01013466126','19400812','M','MEMBER');

-- only test
-- SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'aifirst';
