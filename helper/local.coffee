'use strict'

initLocal = ->
  global.IAM =
    ACCESS    : 'AKIAIU7VD5ZJIWAJPHPA'
    SECRET    : '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'
    REGION    : 'ap-northeast-2'
    BUCKET    : 's3.www.aifirst.kr'

  global.MYSQL =
    HOST      : 'aifirst.cbt97yfhqua0.ap-northeast-2.rds.amazonaws.com'
    PORT      : 3306
    USER      : 'aifirst'
    PASSWORD  : 'aifirst00!!'
    DATABASE  : 'aifirst'

  global.REDIS =
    HOST      : 'redis.aifirst.kr'
    PORT      : 6379
    PASSWORD  : 'aifirst00!!'

  global.GMAIL =
    EMAIL     : 'aifirstkr@gmail.com'
    PASSWORD  : 'aifirst00!!'

  global.SMTP =
    HOST      : 'mxa.mailgun.org'
    PORT      : 465
    EMAIL     : 'aifirst@aifirst.kr'
    PASSWORD  : 'aifirst00!!'

  global.TOKEN =
    TYPE      : 'BEARER'
    SECRET    : 'aifirst'
    EXPIRE_SEC: 1000

module.exports = initLocal()

