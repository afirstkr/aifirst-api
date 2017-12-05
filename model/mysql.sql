drop database aifirst;
create database aifirst;
use aifirst;

create table user (
  id            varchar(100) not null,
  password      varchar(100) not null,
  createdAt     datetime default current_timestamp,
  updatedAt     datetime default current_timestamp on update current_timestamp,
  
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