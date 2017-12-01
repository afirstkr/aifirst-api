'use strict'

channel   = require('express').Router()
validator = require 'validator'
tms       = require '../helper/tms'
acl       = require '../helper/acl'

##################################################
# REST API
##################################################
channel.post '/', tms.verifyToken
#user.post '/', acl.allowManager
channel.post '/', (req, res)->
  unless req.body._id         then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._body       then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._class      then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'insert into _channel set ?'
  param = 
    _id: req.body._id
    _class: CCLASS.POST
    _from: JSON.stringify req.body._from
    _to: JSON.stringify req.body._to
    _body: JSON.stringify req.body._body

  pool.query sql, param, (err, result)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

    sql = 'select * from _channel where _id = ?'
    param = [req.body._id]
    pool.query sql, param, (err, inserted)->
      inserted[0]._from = JSON.parse(inserted[0]._from)
      inserted[0]._to   = JSON.parse(inserted[0]._to)
      inserted[0]._body = JSON.parse(inserted[0]._body)
      return res.json {data: inserted[0]}

# channel.get '/list', tms.verifyToken
#user.post '/list', acl.allowManager
channel.get '/list/:_from', (req, res)->
  unless req.params._from       then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _channel where JSON_CONTAINS(_from, ?)'
  param = [JSON.stringify req.params._from]
  pool.query sql, param, (err, list)->
    return res.json {data: list}

channel.get '/', tms.verifyToken
channel.get '/', (req, res)->
  # check offset & limit
  if  req.query._offset and
      req.query._limit and
      req.query._orderBy and
      req.query._isAsc and
      req.query._isAllClass and
      req.query._isAllState

    if JSON.parse(req.query._isAsc) then ascDesc = 'asc'
    else ascDesc = 'desc'

    if JSON.parse(req.query._isAllClass) then _class = ''
    else _class = UCLASS.ADMIN

    if JSON.parse(req.query._isAllState) then _state = ''
    else _state = USTATE.CONFIRM_REQUIRED

    sql = 'select * from _channel'
    sql += " where _class != '#{_class}' and _state != '#{_state}' order by _createdAt desc, #{req.query._orderBy} #{ascDesc} limit ?,?"

    param = [Number(req.query._offset), Number(req.query._limit)]
    pool.query sql, param, (err, _user)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

      return  res.json {data: _user}

  # check field searching
  else if req.query._userID or
          req.query._userName or
          req.query._mobile or
          req.query._birthdate or
          req.query._sex or
          req.query._class or
          req.query._state or
          req.query._isAllClass or
          req.query._isAllState or
          req.query._createdAt or
          req.query._updatedAt

    if req.query._isAllClass and JSON.parse(req.query._isAllClass) then _class = ''
    else _class = UCLASS.ADMIN

    if req.query._isAllState and JSON.parse(req.query._isAllState) then _state = ''
    else _state = USTATE.CONFIRM_REQUIRED

    sql = '''
      select
        _user._userID,
        _user._userName,
        _user._mobile,
        _user._birthdate,
        _user._sex,
        _user._class,
        _user._state,
        _user._thumbnailURL,
        _user._isResigned,
        _user._createdAt,
        _user._updatedAt,
        _user._deletedAt
      from
        _user
    '''
    where = " where _class != '#{_class}' and _state != '#{_state}' "
    orderBy = ' order by _createdAt desc'

    if req.query._userID     and req.query._userID != ''     then where += " and _userID    =     '#{req.query._userID}'"
    if req.query._userName   and req.query._userName != ''   then where += " and _userName  like '%#{req.query._userName}%'"
    if req.query._mobile     and req.query._mobile != ''     then where += " and _mobile    like '%#{req.query._mobile}%'"
    if req.query._birthdate  and req.query._birthdate != ''  then where += " and _birthdate like '%#{req.query._birthdate}%'"
    if req.query._sex        and req.query._sex != ''        then where += " and _sex       =     '#{req.query._sex}'"
    if req.query._class      and req.query._class != ''      then where += " and _class     =     '#{req.query._class}'"
    if req.query._state      and req.query._state != ''      then where += " and _state     =     '#{req.query._state}'"
    if req.query._createdAt and req.query._createdAt != ''   then where += " and _createdAt like  '#{req.query._createdAt}%'"
    if req.query._updatedAt and req.query._updatedAt != ''   then where += " and _updatedAt like  '#{req.query._updatedAt}%'"

    pool.query sql + where + orderBy, (err, _user)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
      if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
      return res.json {data: _user}

  # take all
  else
    sql = '''
      select
        _user._userID,
        _user._userName,
        _user._mobile,
        _user._birthdate,
        _user._sex,
        _user._class,
        _user._state,
        _user._thumbnailURL,
        _user._isResigned,
        _user._createdAt,
        _user._updatedAt,
        _user._deletedAt
      from
        _user
      order by _createdAt desc
    '''

    pool.query sql, (err, _user)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
      if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
      return res.json {data: _user}


channel.get '/:_userID', tms.verifyToken
channel.get '/:_userID', (req, res)->
  sql = '''
      select
        _user._userID,
        _user._userName,
        _user._mobile,
        _user._birthdate,
        _user._sex,
        _user._class,
        _user._state,
        _user._thumbnailURL,
        _user._isResigned,
        _user._createdAt,
        _user._updatedAt,
        _user._deletedAt
      from
        _user
      where
        _userID = ?
  '''
  param = [req.params._userID]
  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    if JSON.parse(_user[0]['_isResigned']) then return res.status(400).json {data: RCODE.INVALID_USER_INFO}

    return res.json {data: _user[0]}


channel.put '/:_userID', tms.verifyToken
#channel.put '/:_userID', acl.allowManager
#channel.put '/:_userID', verifyReq
channel.put '/:_userID', (req, res)->
  unless req.params._userID  then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _user where _userID = ?'
  param = [req.params._userID]

  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    if JSON.parse(_user[0]['_isResigned']) then return res.status(400).json {data: RCODE.USER_RESIGNED}

    sets = {}

    if req.body._password     then sets._password     = req.body._password
    if req.body._userName     then sets._userName     = req.body._userName
    if req.body._mobile       then sets._mobile       = req.body._mobile
    if req.body._birthdate    then sets._birthdate    = req.body._birthdate
    if req.body._sex          then sets._sex          = req.body._sex
    if req.body._class        then sets._class        = req.body._class
    if req.body._state        then sets._state        = req.body._state
    if req.body._thumbnailURL then sets._thumbnailURL = req.body._thumbnailURL

    if JSON.stringify(sets) == '{}' then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'update _user set ? where _userID = ?'
    param = [sets, req.params._userID]
    pool.query sql, param, (err, result)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

      sets._userID = req.params._userID
      return res.json {data: sets}


channel.delete '/:_userID', tms.verifyToken
#channel.delete '/:_userID', acl.allowManager
channel.delete '/:_userID', (req, res)->
  unless req.params._userID  then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _user where _userID = ?'
  param = [req.params._userID]
  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    if JSON.parse(_user[0]['_isResigned']) then return res.status(400).json {data: RCODE.USER_RESIGNED}

    sql = 'update _user set _isResigned = ?, _deletedAt = ? where _userID = ?'
    param = [true, new Date(), req.params._userID]
    pool.query sql, param, (err, result)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

      return res.json {data: RCODE.DELETE_SUCCEED}


module.exports = channel