'use strict'

express    = require 'express'
tms        = require '../helper/tms'
nodemailer = require 'nodemailer'
otpGen     = require '../helper/otp'
auth       = express.Router()

######################################################################
# SPECIAL API
######################################################################
auth.post '/signup', (req, res) ->
  unless req.body.email     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.password  then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.userName  then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.otp       then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    value = await redis.get req.body.email
    unless value then return res.status(500).json {data: RCODE.OTP_EXPIRED}
    otp = JSON.parse(value)

    if otp.code != req.body.otp
      return res.status(400).json {data: RCODE.INVALID_OTP_CODE}

    sql = 'select * from user where email = ?'
    param = [req.body.email]
    user = await pool.query sql, param

    if user.length > 0 then return res.status(400).json {data: RCODE.EMAIL_EXISTS}

    sql = 'insert into user set ?'
    param =
      email:    req.body.email
      password: req.body.password
      userName: req.body.userName

    await pool.query sql, param

    sql = 'select * from user where email = ?'
    param = [req.body.email]
    user = await pool.query sql, param
    return res.json {data: user[0]}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


auth.post '/login', (req, res) ->
  unless req.body.email     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.password  then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    # check user info
    sql = 'select * from user where email = ? and password = ? and isRemoved = false'
    param = [req.body.email, req.body.password]

    user = await pool.query sql, param
    if user.length < 1 then return res.status(400).json {data: RCODE.INVALID_LOGIN_INFO}

    sql = 'select count(*) as uclass from channel where channelID = "admin" and  JSON_CONTAINS(manager, ?)'
    param = JSON.stringify {manager: req.body.email}

    uclass = await pool.query sql, param
    if uclass.length > 0
      uclass = 'ADMIN'
    else
      uclass = 'USER'

    payload =
      email:    user[0].email
      userName: user[0].userName
      uclass:   uclass

    token = tms.jwt.sign payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC}
    unless token then return res.status(500).json {data: RCODE.SERVER_ERROR}
    return res.json {data: token}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


auth.post '/logout', tms.verifyToken
auth.post '/logout', (req, res) ->
  tms.addBlacklist req.token
  delete req.token
  return res.json {data: RCODE.LOGOUT_SUCCEED}


auth.get '/me', tms.verifyToken
auth.get '/me', (req, res) -> res.json {data: req.token}

auth.put '/me', tms.verifyToken
auth.put '/me', (req, res) ->
  try
    sql = 'select * from user where email=? and isRemoved=false'
    param = [req.token.email]

    user = await pool.query sql, param

    if user.length < 1 then return res.status(400).json {data: RCODE.INVALID_TOKEN}

    sets = {}

    if req.body.password    then sets.password    = req.body.password
    if req.body.userName    then sets.userName    = req.body.userName
    if req.body.mobile      then sets.mobile      = req.body.mobile
    if req.body.channel     then sets.channel     = req.body.channel
    if req.body.photo       then sets.photo       = req.body.photo
    if req.body.bizName     then sets.bizName     = req.body.bizName
    if req.body.bizRegCode  then sets.bizRegCode  = req.body.bizRegCode
    if req.body.bizPhone    then sets.bizPhone    = req.body.bizPhone

    if JSON.stringify sets is '{}' then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'update user set ? where email=?'
    param = [sets, req.token.email]

    await pool.query sql, param

    sql = 'select * from user where email=?'
    param = [req.token.email]

    user = await pool.query sql, param

    payload =
      email:    user[0].email
      userName: user[0].userName

    token = tms.jwt.sign payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC}

    unless token then return res.status(500).json {data: RCODE.SERVER_ERROR}
    tms.addBlacklist req.token
    delete req.token
    return res.json {data: token}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


auth.post '/leave', tms.verifyToken
auth.post '/leave', (req, res) ->
  unless req.body.email     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.password  then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    sql = 'select * from email=? and password=? isRemoved=false'
    param = [req.body.email, req.body.password]
    user = await pool.query sql, param

    if user.length < 1 then return res.status(400).json {data: RCODE.INVALID_USER_INFO}

    sets = {}
    sets.isRemoved = true
    sets.removedAt = new Date()

    sql = 'update user set ? where email=?'
    param = [sets, req.token.email]

    await pool.query sql, param
    return res.json {data: RCODE.OPERATION_SUCCEED}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


auth.post '/sendOtpEmail', (req, res) ->
  unless req.body.email     then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    otp = otpGen.makeOtp()

    config =
        host: SMTP.HOST
        port: SMTP.PORT
        secure: true
        auth:
          user: SMTP.EMAIL
          pass: SMTP.PASSWORD

    transport = nodemailer.createTransport config

    message =
      from:    '인증확인 <noreply@aifirst.kr>'
      to:      req.body.email
      subject: '인증코드를 확인해 주세요.'
      html:    "귀하의 인증코드는 <b style='color:red'>#{otp.code}</b> 입니다."

    await transport.sendMail message
    redis.set req.body.email, JSON.stringify otp
    redis.expire req.body.email, otp.ttl
    return res.json {data: RCODE.EMAIL_REQUEST_SUCCEED}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}

module.exports = auth