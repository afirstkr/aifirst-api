'use strict'

express   = require 'express'
tms       = require '../helper/tms'
acl       = require '../helper/acl'
user      = express.Router()

######################################################################
# SPECIAL API
######################################################################
user.get '/me', tms.verifyToken
user.get '/me', (req, res) ->
  return res.json {data: req.token}

user.put '/me', tms.verifyToken
user.put '/me', (req, res) ->
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

    if Object.keys(sets).length is 0 then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'update user set ? where email=?'
    param = [sets, req.token.email]
    await pool.query sql, param

    sql = 'select * from user where email=?'
    param = [req.token.email]
    user = await pool.query sql, param

    sql = 'select count(*) as uclass from channel where channelID="admin" and  JSON_CONTAINS(manager, ?)'
    param = JSON.stringify {manager: req.token.email}

    uclass = await pool.query sql, param
    if uclass[0].uclass > 0
      uclass = UCLASS.ADMIN
    else
      uclass = UCLASS.USER

    payload =
      email:    user[0].email
      userName: user[0].userName
      uclass:   uclass

    token = tms.jwt.sign payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC}
    unless token then return res.status(500).json {data: RCODE.SERVER_ERROR}

    tms.addBlacklist req.token
    delete req.token
    return res.json {data: token}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


######################################################################
# REST API
######################################################################
user.post '/', tms.verifyToken
user.post '/', acl.allowManager
user.post '/', (req, res) ->
  unless req.body.email then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.password then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.userName then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.mobile then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    sql = 'select * from user where email = ?'
    param = [req.body.email]
    user = await pool.query sql, param
    if user.length > 0 then return res.status(400).json {data: RCODE.USERNAME_EXISTS}

    sql = 'insert into user set ?'
    param =
      email:    req.body.email
      password: req.body.password
      userName: req.body.userName
      mobile:   req.body.mobile

    await pool.query sql, param
    sql = 'select * from user where email = ?'
    param = [req.body.email]
    user = await pool.query sql, param
    return res.json {data: user[0]}

  catch err
    log 'err=',err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


user.get '/', tms.verifyToken
user.get '/', (req, res) ->
  unless req.query.page   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.query.size   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.query.preset then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    switch req.query.preset
      when QUERY.USER_DEFAULT then sql = 'select * from user where isRemoved=false order by createdAt desc limit ?,?'
      else return res.status(400).json {data: RCODE.INVALID_PARAMS}

    total = await pool.query 'select count(*) as total from user where isRemoved=false'
    total = total[0].total
    size  = parseInt req.query.size
    page  = parseInt req.query.page
    pages = Math.ceil total / size
    offset = (page - 1) * size

    result =
      meta :
        total : total
        pages : pages
        size  : size
        page  : req.query.page
        offset: offset

    param = [offset, size]
    user = await pool.query sql, param

    # for simple query string
    for u in user
      delete u.password
      delete u.score
      delete u.coin

    result.data = user

    return res.status(200).json result

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


user.get '/:email', tms.verifyToken
user.get '/:email', (req, res) ->
  try
    sql = 'select * from user where email=? and isRemoved=false'
    param = [req.params.email]

    user = await pool.query sql, param
    if user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}

    # for simple query string
    delete user[0].password
    delete user[0].score
    delete user[0].coin

    return res.json {data: user[0]}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}

user.put '/:email', tms.verifyToken
user.put '/:email', acl.allowManager
user.put '/:email', (req, res) ->
  try
    sql = 'select * from user where email=? and isRemoved=false'
    param = [req.params.email]

    user = await pool.query sql, param

    if user.length < 1 then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sets = {}

    if req.body.password    then sets.password    = req.body.password
    if req.body.userName    then sets.userName    = req.body.userName
    if req.body.mobile      then sets.mobile      = req.body.mobile
    if req.body.channel     then sets.channel     = req.body.channel
    if req.body.photo       then sets.photo       = req.body.photo
    if req.body.bizName     then sets.bizName     = req.body.bizName
    if req.body.bizRegCode  then sets.bizRegCode  = req.body.bizRegCode
    if req.body.bizPhone    then sets.bizPhone    = req.body.bizPhone

    if Object.keys(sets).length is 0 then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'update user set ? where email=?'
    param = [sets, req.params.email]
    await pool.query sql, param

    sql = 'select * from user where email=?'
    param = [req.params.email]
    user = await pool.query sql, param
    delete user[0].password
    delete user[0].score
    delete user[0].coin

    return res.json {data: user[0]}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


user.delete '/:email', tms.verifyToken
user.delete '/:email', acl.allowManager
user.delete '/:email', (req, res) ->
  try
    sql = 'select * from user where email=? and isRemoved=false'
    param = [req.params.email]
    user = await pool.query sql, param

    if user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}

    sql = 'update user set isRemoved=?, removedAt=? where email=?'
    param = [true, new Date(), req.params.email]
    await pool.query sql, param

    return res.json {data: RCODE.OPERATION_SUCCEED}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


module.exports = user