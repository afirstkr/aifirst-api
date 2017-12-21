'use strict'

express   = require 'express'
validator = require 'validator'
tms       = require '../helper/tms'
acl       = require '../helper/acl'
post      = express.Router()

######################################################################
# REST API
######################################################################
post.post '/', tms.verifyToken
post.post '/', (req, res) ->
  unless req.body.channelID then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.email     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.userName  then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.title     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body.html      then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    sql = 'insert into post set ?'
    param =
      channelID:  req.body.channelID
      email:      req.body.email
      userName:   req.body.userName
      title:      req.body.title
      html:       req.body.html

    post = await pool.query sql, param

    return res.json {data: post.insertId}

  catch err
    log 'err=',err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


post.get '/', (req, res) ->
  unless req.query.page   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.query.size   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.query.preset then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  try
    switch req.query.preset
      when 'NOTICE_DEFAULT' then channelID = 'notice'
      when 'FREE_DEFAULT'   then channelID = 'free'
      when 'MOIM_DEFAULT'   then channelID = 'moim'
      # 불편하네..
      else return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'select count(*) as total from post where channelID=?'
    param = [channelID]
    total = await pool.query sql, param
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
        page  : page
        offset: offset

    sql = 'select * from post where channelID=? order by createdAt desc limit ?,?'
    param = [channelID, offset, size]
    post = await pool.query sql, param
    result.data = post

    return res.status(200).json result

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


post.get '/:id', (req, res) ->
  try
    sql = 'select * from post where postID=?'
    param = [req.params.id]

    post = await pool.query sql, param
    if post.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}

    return res.json {data: post[0]}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


post.put '/:postID', (req, res) ->
  try
    sets = {}

    if req.body.tag   then sets.tag    = req.body.tag
    if req.body.title then sets.title  = req.body.title
    if req.body.html  then sets.html   = req.body.html

    if Object.keys(sets).length is 0 then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'update post set ? where postID=?'
    param = [sets, req.params.postID]
    await pool.query sql, param

    sql = 'select * from post where postID=?'
    param = [req.params.postID]
    post = await pool.query sql, param

    return res.json {data: post[0]}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}


post.delete '/:postID', (req, res) ->
  try
    sql = 'delete from post where postID=?'
    param = [req.params.postID]
    await pool.query sql, param

    return res.json {data: req.params.postID}

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}

module.exports = post