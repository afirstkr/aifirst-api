drop database aifirst;
create database aifirst;
use aifirst;

-- system table
create table user (
  email       varchar(1000) not null,
  pass        varchar(1000) not null,
  nickname    varchar(1000) not null,
  isRealName  boolean       default 0,
  isConfirmed boolean       default 0,
  mobile      varchar(1000) default null,
  phone       varchar(1000) default null,
  actScore    bigint        default 0,
  bbsList     json          default null,
  thumbUrl    varchar(1000) default null,
  bgUrl       varchar(1000) default null,
  bizName     varchar(1000) default null,
  bizRegCode  varchar(1000) default null,

  isRemoved   boolean       default 0,
  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key (email),
  key         (nickname),
  key         (isConfirmed),
  key         (mobile),
  key         (phone),
  key         (actScore),
  key         (isRemoved),
  key         (createdAt)
)engine=InnoDB default charset=utf8;

create table adminBBS (
  bbsID       varchar(1000) not null,
  bbsName     varchar(1000) not null,
  sysopList   json          not null,
  intro       longtext,
  thumbUrl    varchar(1000) default null,
  bgUrl       varchar(1000) default null,

  isRemoved   boolean       default 0,
  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key (bbsID),
  key         (bbsName),
  key         (isRemoved),
  key         (createdAt)
)engine=InnoDB default charset=utf8;

-- sequence function
create table seq (
  name          varchar(1000) not null,
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

-- bbs table
create table noticePost (
  postID      bigint        not null auto_increment,
  nickname    varchar(1000) not null,
  title       varchar(1000) not null,
  html        longtext,
  views       bigint        default 0,
  likes       bigint        default 0,
  tag         varchar(1000) default null,

  isRemoved   boolean       default 0,
  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key   (postID),
  key           (nickname),
  key           (title),
  fulltext key  (html),
  key           (tag),
  key           (createdAt)
)engine=InnoDB default charset=utf8;

create table noticeReply (
  replyID     bigint        not null auto_increment,
  postID      bigint        not null,
  nickname    varchar(1000) not null,
  html        longtext,
  likes       bigint        default 0,

  isRemoved   boolean       default 0,
  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key (replyID),
  key         (postID),
  key         (createdAt)
)engine=InnoDB default charset=utf8;


-- bulk insert
-- insert into user (id, password) values ('admin1', 'admin1');

-- check UTF-9
-- select default_character_set_name, default_collation_name from information_schema.schemata where schema_name = 'aifirst';

-- check aws rds params
-- show global variables like 'log_bin_trust_function_creators';
-- aws rds params 'log_bin_trust_function_creators = 1';