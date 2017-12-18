drop database aifirst;
create database aifirst;
use aifirst;
  
-- system table
create table user (
  email       varchar(1000) not null,
  password    varchar(1000) not null,
  userName    varchar(1000) not null,
  mobile      varchar(1000) default null,
  score       bigint        default 0,
  coin        bigint        default 0,
  channel     json          default null,
  photo       varchar(1000) default null,
  bizName     varchar(1000) default null,
  bizRegCode  varchar(1000) default null,
  bizPhone    varchar(1000) default null,

  isRemoved   boolean       default 0,
  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key (email),
  key         (userName),
  key         (mobile),
  key         (score),
  key         (isRemoved),
  key         (createdAt)
)engine=InnoDB default charset=utf8;

create table channel (
  channelID   varchar(1000) not null,
  channelName varchar(1000) not null,
  manager     json          not null,
  intro       longtext,
  thumbUrl    varchar(1000) default null,
  bgUrl       varchar(1000) default null,

  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key (channelID),
  key         (channelName),
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

-- channel table
create table post (
  postID      bigint        not null auto_increment,
  channelID   varchar(1000) not null,
  tag         varchar(1000) default null,
  email       varchar(1000) not null,
  photo       varchar(1000) not null,
  userName    varchar(1000) not null,
  title       varchar(1000) not null,
  html        longtext,
  views       bigint        default 0,
  likes       bigint        default 0,

  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key   (postID),
  key           (channelID),
  key           (tag),
  key           (title),
  fulltext key  (html),
  key           (views),
  key           (likes),
  key           (createdAt)
)engine=InnoDB default charset=utf8;

create table reply (
  replyID     bigint        not null auto_increment,
  postID      bigint        not null,
  email       varchar(1000) not null,
  userName    varchar(1000) not null,
  photo       varchar(1000) not null,
  html        longtext,
  likes       bigint        default 0,

  createdAt   datetime      default current_timestamp,
  updatedAt   datetime      default current_timestamp on update current_timestamp,
  removedAt   datetime      default null,

  primary key (replyID),
  key         (postID),
  key         (createdAt)
)engine=InnoDB default charset=utf8;


-- init table
insert into channel (channelID, channelName, manager) values ('admin', 'admin', '{"manager":["admin1@aifirst.kr","admin2@aifirst.kr"]}');
insert into user (email, password, userName) values ('admin1@aifirst.kr', 'admin1', 'admin1');
insert into user (email, password, userName) values ('admin2@aifirst.kr', 'admin2', 'admin2');

-- bulk insert
insert into user (email, password, userName) values ('user1@aifirst.kr', 'user1', 'user1');
insert into user (email, password, userName) values ('user2@aifirst.kr', 'user2', 'user2');
insert into user (email, password, userName) values ('user3@aifirst.kr', 'user3', 'user3');
insert into user (email, password, userName) values ('user4@aifirst.kr', 'user4', 'user4');
insert into user (email, password, userName) values ('user5@aifirst.kr', 'user5', 'user5');
insert into user (email, password, userName) values ('user6@aifirst.kr', 'user6', 'user6');
insert into user (email, password, userName) values ('user7@aifirst.kr', 'user7', 'user7');
insert into user (email, password, userName) values ('user8@aifirst.kr', 'user8', 'user8');
insert into user (email, password, userName) values ('user9@aifirst.kr', 'user9', 'user9');
insert into user (email, password, userName) values ('user10@aifirst.kr', 'user10', 'user10');
insert into user (email, password, userName) values ('user11@aifirst.kr', 'user11', 'user11');
insert into user (email, password, userName) values ('user12@aifirst.kr', 'user12', 'user12');
insert into user (email, password, userName) values ('user13@aifirst.kr', 'user13', 'user13');
insert into user (email, password, userName) values ('user14@aifirst.kr', 'user14', 'user14');
insert into user (email, password, userName) values ('user15@aifirst.kr', 'user15', 'user15');
insert into user (email, password, userName) values ('user16@aifirst.kr', 'user16', 'user16');
insert into user (email, password, userName) values ('user17@aifirst.kr', 'user17', 'user17');
insert into user (email, password, userName) values ('user18@aifirst.kr', 'user18', 'user18');
insert into user (email, password, userName) values ('user19@aifirst.kr', 'user19', 'user19');
insert into user (email, password, userName) values ('user20@aifirst.kr', 'user20', 'user20');
insert into user (email, password, userName) values ('user21@aifirst.kr', 'user21', 'user21');
insert into user (email, password, userName) values ('user22@aifirst.kr', 'user22', 'user22');
insert into user (email, password, userName) values ('user23@aifirst.kr', 'user23', 'user23');
insert into user (email, password, userName) values ('user24@aifirst.kr', 'user24', 'user24');
insert into user (email, password, userName) values ('user25@aifirst.kr', 'user25', 'user25');
insert into user (email, password, userName) values ('user26@aifirst.kr', 'user26', 'user26');
insert into user (email, password, userName) values ('user27@aifirst.kr', 'user27', 'user27');
insert into user (email, password, userName) values ('user28@aifirst.kr', 'user28', 'user28');
insert into user (email, password, userName) values ('user29@aifirst.kr', 'user29', 'user29');
insert into user (email, password, userName) values ('user30@aifirst.kr', 'user30', 'user30');
insert into user (email, password, userName) values ('user31@aifirst.kr', 'user31', 'user31');
insert into user (email, password, userName) values ('user32@aifirst.kr', 'user32', 'user32');
insert into user (email, password, userName) values ('user33@aifirst.kr', 'user33', 'user33');
insert into user (email, password, userName) values ('user34@aifirst.kr', 'user34', 'user34');
insert into user (email, password, userName) values ('user35@aifirst.kr', 'user35', 'user35');
insert into user (email, password, userName) values ('user36@aifirst.kr', 'user36', 'user36');
insert into user (email, password, userName) values ('user37@aifirst.kr', 'user37', 'user37');
insert into user (email, password, userName) values ('user38@aifirst.kr', 'user38', 'user38');
insert into user (email, password, userName) values ('user39@aifirst.kr', 'user39', 'user39');
insert into user (email, password, userName) values ('user40@aifirst.kr', 'user40', 'user40');
insert into user (email, password, userName) values ('user41@aifirst.kr', 'user41', 'user41');
insert into user (email, password, userName) values ('user42@aifirst.kr', 'user42', 'user42');
insert into user (email, password, userName) values ('user43@aifirst.kr', 'user43', 'user43');
insert into user (email, password, userName) values ('user44@aifirst.kr', 'user44', 'user44');
insert into user (email, password, userName) values ('user45@aifirst.kr', 'user45', 'user45');
insert into user (email, password, userName) values ('user46@aifirst.kr', 'user46', 'user46');
insert into user (email, password, userName) values ('user47@aifirst.kr', 'user47', 'user47');
insert into user (email, password, userName) values ('user48@aifirst.kr', 'user48', 'user48');
insert into user (email, password, userName) values ('user49@aifirst.kr', 'user49', 'user49');
insert into user (email, password, userName) values ('user50@aifirst.kr', 'user50', 'user50');
insert into user (email, password, userName) values ('user51@aifirst.kr', 'user51', 'user51');
insert into user (email, password, userName) values ('user52@aifirst.kr', 'user52', 'user52');
insert into user (email, password, userName) values ('user53@aifirst.kr', 'user53', 'user53');
insert into user (email, password, userName) values ('user54@aifirst.kr', 'user54', 'user54');
insert into user (email, password, userName) values ('user55@aifirst.kr', 'user55', 'user55');
insert into user (email, password, userName) values ('user56@aifirst.kr', 'user56', 'user56');
insert into user (email, password, userName) values ('user57@aifirst.kr', 'user57', 'user57');
insert into user (email, password, userName) values ('user58@aifirst.kr', 'user58', 'user58');
insert into user (email, password, userName) values ('user59@aifirst.kr', 'user59', 'user59');
insert into user (email, password, userName) values ('user60@aifirst.kr', 'user60', 'user60');
insert into user (email, password, userName) values ('user61@aifirst.kr', 'user61', 'user61');
insert into user (email, password, userName) values ('user62@aifirst.kr', 'user62', 'user62');
insert into user (email, password, userName) values ('user63@aifirst.kr', 'user63', 'user63');
insert into user (email, password, userName) values ('user64@aifirst.kr', 'user64', 'user64');
insert into user (email, password, userName) values ('user65@aifirst.kr', 'user65', 'user65');
insert into user (email, password, userName) values ('user66@aifirst.kr', 'user66', 'user66');
insert into user (email, password, userName) values ('user67@aifirst.kr', 'user67', 'user67');
insert into user (email, password, userName) values ('user68@aifirst.kr', 'user68', 'user68');
insert into user (email, password, userName) values ('user69@aifirst.kr', 'user69', 'user69');
insert into user (email, password, userName) values ('user70@aifirst.kr', 'user70', 'user70');
insert into user (email, password, userName) values ('user71@aifirst.kr', 'user71', 'user71');
insert into user (email, password, userName) values ('user72@aifirst.kr', 'user72', 'user72');
insert into user (email, password, userName) values ('user73@aifirst.kr', 'user73', 'user73');
insert into user (email, password, userName) values ('user74@aifirst.kr', 'user74', 'user74');
insert into user (email, password, userName) values ('user75@aifirst.kr', 'user75', 'user75');
insert into user (email, password, userName) values ('user76@aifirst.kr', 'user76', 'user76');
insert into user (email, password, userName) values ('user77@aifirst.kr', 'user77', 'user77');
insert into user (email, password, userName) values ('user78@aifirst.kr', 'user78', 'user78');
insert into user (email, password, userName) values ('user79@aifirst.kr', 'user79', 'user79');
insert into user (email, password, userName) values ('user80@aifirst.kr', 'user80', 'user80');
insert into user (email, password, userName) values ('user81@aifirst.kr', 'user81', 'user81');
insert into user (email, password, userName) values ('user82@aifirst.kr', 'user82', 'user82');
insert into user (email, password, userName) values ('user83@aifirst.kr', 'user83', 'user83');
insert into user (email, password, userName) values ('user84@aifirst.kr', 'user84', 'user84');
insert into user (email, password, userName) values ('user85@aifirst.kr', 'user85', 'user85');
insert into user (email, password, userName) values ('user86@aifirst.kr', 'user86', 'user86');
insert into user (email, password, userName) values ('user87@aifirst.kr', 'user87', 'user87');
insert into user (email, password, userName) values ('user88@aifirst.kr', 'user88', 'user88');
insert into user (email, password, userName) values ('user89@aifirst.kr', 'user89', 'user89');
insert into user (email, password, userName) values ('user90@aifirst.kr', 'user90', 'user90');
insert into user (email, password, userName) values ('user91@aifirst.kr', 'user91', 'user91');
insert into user (email, password, userName) values ('user92@aifirst.kr', 'user92', 'user92');
insert into user (email, password, userName) values ('user93@aifirst.kr', 'user93', 'user93');
insert into user (email, password, userName) values ('user94@aifirst.kr', 'user94', 'user94');
insert into user (email, password, userName) values ('user95@aifirst.kr', 'user95', 'user95');
insert into user (email, password, userName) values ('user96@aifirst.kr', 'user96', 'user96');
insert into user (email, password, userName) values ('user97@aifirst.kr', 'user97', 'user97');
insert into user (email, password, userName) values ('user98@aifirst.kr', 'user98', 'user98');
insert into user (email, password, userName) values ('user99@aifirst.kr', 'user99', 'user99');
insert into user (email, password, userName) values ('user100@aifirst.kr', 'user100', 'user100');

-- check UTF-9
-- select default_character_set_name, default_collation_name from information_schema.schemata where schema_name = 'aifirst';

-- check aws rds params
-- show global variables like 'log_bin_trust_function_creators';
-- aws rds params 'log_bin_trust_function_creators = 1';