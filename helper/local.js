`use strict`

let initLocal = ()=>{
  global.MYSQL = {
    HOST      : `aifirst.cbt97yfhqua0.ap-northeast-2.rds.amazonaws.com`,
    PORT      : 3306,
    USER      : `aifirst`,
    PASSWORD  : `aifirst00!!`,
    DATABASE  : `aifirst`
  }

  global.REDIS = {
    HOST      : `redis.aifirst.kr`,
    PORT      : 6379,
    PASSWORD  : `aifirst00!!`
  }

  global.APP = {
    HOST      : 'localhost',
    PORT      : 8081
  }

  global.TOKEN = {
    TYPE      : `BEARER`,
    SECRET    : `aifirst`,
    EXPIRE_SEC: 1000
  }
}
    
module.exports = initLocal()
