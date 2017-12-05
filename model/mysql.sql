drop database aifirst;
create database aifirst;
use aifirst;

create table user (
  email         varchar(100)  not null,
  password      varchar(100)  not null,
  name          varchar(100)  default null,
  mobile        varchar(100)  default null,
  phone         varchar(100)  default null,
  point         bigint        default 0,
  thumbUrl      varchar(100)  default null,
  bizName       varchar(100)  default null,
  bizRegCode    varchar(100)  default null,
  myBbs         json          default null,
  createdAt     datetime      default current_timestamp,
  updatedAt     datetime      default current_timestamp on update current_timestamp,
  removedAt     datetime      default null,
  
  primary key   (email),
  key           (name),
  key           (mobile),
  key           (phone),
  key           (point),
  key           (createdAt)
)engine=InnoDB default charset=utf8;

create table bbs_info (
  id            varchar(100)  not null,
  name          varchar(100)  not null,
  desc          varchar(100)  default null,
  thumbUrl      varchar(100)  default null,

  sysop1        varchar(100)  default null,
  sysop2        varchar(100)  default null,
  sysop3        bigint        default 0,
  sysop4        varchar(100)  default null,
  sysop5
  createdAt     datetime      default current_timestamp,
  updatedAt     datetime      default current_timestamp on update current_timestamp,
  removedAt     datetime      default null,
  
  primary key   (id),
  key           (createdAt)
)engine=InnoDB default charset=utf8;




-- sequence function
create table seq (
  name          varchar(100) not null,
  val           bigint       not null,

  primary key   (name)
)engine=InnoDB default charset=utf8;

delimiter ;;
create function nextSeq()
  returns bigint
  modifies sql data
  sql security invoker
  deterministic
begin
  insert into seq
    set name='default', val=(@v_current_value:=1)
  on duplicate key
    update val=(@v_current_value:=val+1);
  return @v_current_value;
end ;;
delimiter ;


-- bulk insert
-- insert into user (id, password) values ('admin1', 'admin1');

-- check UTF-9
-- select default_character_set_name, default_collation_name from information_schema.schemata where schema_name = 'aifirst';

-- check aws rds params
-- show global variables like 'log_bin_trust_function_creators';
-- aws rds params 'log_bin_trust_function_creators = 1';