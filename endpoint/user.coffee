'use strict'

user      = require('express').Router()
validator = require 'validator'
tms       = require '../helper/tms'
acl       = require '../helper/acl'

##################################################
# logic condition validator
##################################################
#verifyReq = (req, res, next)->
#  if req.method == 'PUT' and req.body._TEST_PARAM == TEST_CONDITION
#    log 'CHANGE ANY CONDITION HERE'
#  else
#    return next()


##################################################
# HELPER API
##################################################
user.get '/helper/stateGroup', tms.verifyToken
user.get '/helper/stateGroup', (req, res)->
  unless req.query._stateGroup then return res.status(400).json {data: RCODE.INVALID_PARAMS}

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

  where = ''
  orderBy = ' order by _createdAt desc'

  if req.query._stateGroup == USTATE_GROUP.HIRED
    where = " where _state = 'WORK' or _state = 'OFF' or _state = 'EARLY_OFF' or _state = 'SICK_OFF' or _state = 'HIRED' "
  else if req.query._stateGroup == USTATE_GROUP.NO_HIRED
    where = " where _state = 'CONFIRM_REQUIRED' or _state = 'READY' "
  else if req.query._stateGroup == USTATE_GROUP.LEAVE
    where = " where _state = 'LEAVE' "
  else return res.status(400).json {data: RCODE.INVALID_PARAMS}

  log 'sql =', sql + where + orderBy

  pool.query sql + where + orderBy, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.json {data: RCODE.NO_RESULT}
    else return res.json {data: _user}

user.get '/helper/isExistsMobile', tms.verifyToken
user.get '/helper/isExistsMobile', (req, res)->
  unless req.query._mobile then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _user where _mobile = ?'
  param = [req.query._mobile]

  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length > 0 then return res.json {data: true}
    else return res.json {data: false}


user.get '/helper/hiredUserList', tms.verifyToken
user.get '/helper/hiredUserList', (req, res)->
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
      _class != 'ADMIN' and _state != 'CONFIRM_REQUIRED'
    order by _createdAt desc
  '''

  pool.query sql, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    return res.json {data: _user}


user.get '/helper/stateReportWithManager', tms.verifyToken
user.get '/helper/stateReportWithManager', (req, res)->
  sql = '''
    select
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and (_state='WORK' or _state='OFF' or _state='SICK_OFF' or _state='EARLY_OFF')) as _total,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='WORK') as _work,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='OFF') as _off,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='SICK_OFF') as _sickOff,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='EARLY_OFF') as _earlyOff
  '''

  pool.query sql, (err, result)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if result.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    return res.json {data: result[0]}

user.get '/helper/stateReportWithoutManager', tms.verifyToken
user.get '/helper/stateReportWithoutManager', (req, res)->
  sql = '''
    select
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and (_state='WORK' or _state='OFF' or _state='SICK_OFF' or _state='EARLY_OFF')) as _total,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='WORK') as _work,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='OFF') as _off,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='SICK_OFF') as _sickOff,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='EARLY_OFF') as _earlyOff
  '''

  pool.query sql, (err, result)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if result.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    return res.json {data: result[0]}


user.post '/helper/findMyID', (req, res)->
  unless req.body._userName then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._mobile then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless validator.isMobilePhone(req.body._mobile, 'ko-KR') then return res.status(400).json {data: RCODE.INVALID_MOBILE_INFO}
  unless req.body._code then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  # init mobile string
  req.body._mobile = req.body._mobile.replace(/-/g,"")

  sql = 'select * from _user where _userName = ? and _mobile = ?'
  param = [req.body._userName, req.body._mobile]
  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

    # validate userName and mobile
    if _user.length < 1 then return res.status(400).json {data: RCODE.INVALID_USER_INFO}

    # validate otp and mobile
    redis.get req.body._mobile, (err, value) ->
      if err
        log 'err', err
        return res.status(500).json {data: RCODE.SERVER_ERROR}

      unless value then return res.status(500).json {data: RCODE.OTP_EXPIRED}

      otp = JSON.parse(value)

      if otp.code == req.body._code
        return res.json {data: _user[0]._userID}
      else
        return res.status(400).json {data: RCODE.INVALID_OTP_CODE}


user.post '/helper/resetMyPassword', (req, res)->
  unless req.body._userID then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._mobile then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless validator.isMobilePhone(req.body._mobile, 'ko-KR') then return res.status(400).json {data: RCODE.INVALID_MOBILE_INFO}
  unless req.body._code then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._password then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  # init mobile string
  req.body._mobile = req.body._mobile.replace(/-/g,"")

  sql = 'select * from _user where _userID = ? and _mobile = ?'
  param = [req.body._userID, req.body._mobile]
  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

    # validate userID and mobile
    if _user.length < 1 then return res.status(400).json {data: RCODE.INVALID_USER_INFO}

    # validate otp and mobile
    redis.get req.body._mobile, (err, value) ->
      if err
        log 'err', err
        return res.status(500).json {data: RCODE.SERVER_ERROR}

      unless value then return res.status(500).json {data: RCODE.OTP_EXPIRED}

      otp = JSON.parse(value)

      if otp.code == req.body._code
        sets = {}
        sets._password = req.body._password
        sql = 'update _user set ? where _userID = ?'
        param = [sets, req.body._userID]
        pool.query sql, param, (err, result)->
          if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

          return res.json {data: RCODE.RESET_MY_PW_SUCCEED}
      else
        return res.status(400).json {data: RCODE.INVALID_OTP_CODE}



##################################################
# SPECIAL API
##################################################
user.post '/signup', (req, res)->
  unless req.body._userID      then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._password    then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._userName    then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._mobile      then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._birthdate   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._sex         then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _user where _userID = ?'
  param = [req.body._userID]

  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length > 0 then return res.status(400).json {data: RCODE.USERNAME_EXISTS}

    sql = 'insert into _user set ?'
    param =
      _userID:       req.body._userID
      _password:     req.body._password
      _userName:     req.body._userName
      _mobile:       req.body._mobile
      _birthdate:    req.body._birthdate
      _sex:          req.body._sex
      _class:        UCLASS.MEMBER
      _state:        USTATE.CONFIRM_REQUIRED

    pool.query sql, param, (err, result)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

      sql = 'select * from _user where _userID = ?'
      param = [req.body._userID]
      pool.query sql, param, (err, inserted)->
        return res.json {data: inserted[0]}


user.post '/login', (req, res)->
  unless req.body._loginType then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._userID   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._password then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  # check user info
  sql = 'select * from _user where _userID = ? and _password = ?'
  param = [req.body._userID, req.body._password]

  pool.query sql, param, (err, userInfo)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if userInfo.length < 1 then return res.status(400).json {data: RCODE.INVALID_LOGIN_INFO}
    if userInfo[0]._state == USTATE.CONFIRM_REQUIRED then return res.status(400).json {data: RCODE.USER_CONFIRM_REQUIRED}
    if JSON.parse(userInfo[0]._isResigned) then return res.status(400).json {data: RCODE.USER_RESIGNED}

    payload =
      _userID:    userInfo[0]._userID
      _userName:  userInfo[0]._userName
      _class:     userInfo[0]._class

    token = tms.jwt.sign payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC}
    unless token then return res.status(500).json {data: RCODE.SERVER_ERROR}
    return res.json {data: token}


user.post '/logout', tms.verifyToken
user.post '/logout', (req, res)->
  tms.addBlacklist req.token
  delete req.token
  return res.json {data: RCODE.LOGOUT_SUCCEED}


user.get '/me', tms.verifyToken
user.get '/me', (req, res)->
  return res.json {data: req.token}

user.put '/me', tms.verifyToken
#user.put '/me', verifyReq
user.put '/me', (req, res)->
  sql = 'select * from _user where _userID = ?'
  param = [req.token._userID]

  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.status(400).json {data: RCODE.INVALID_TOKEN}
    if JSON.parse(_user[0]['_isResigned']) then return res.status(400).json {data: RCODE.USER_RESIGNED}

    sets = {}
    where = {username: req.token._userID}

    if req.body._userName     then sets._userName     = req.body._userName
    if req.body._password     then sets._password     = req.body._password
    if req.body._mobile       then sets._mobile       = req.body._mobile
    if req.body._birthdate    then sets._birthdate    = req.body._birthdate
    if req.body._sex          then sets._sex          = req.body._sex
    if req.body._state        then sets._state        = req.body._state
    if req.body._thumbnailURL then sets._thumbnailURL = req.body._thumbnailURL

    if JSON.stringify(sets) == '{}' then return res.status(400).json {data: RCODE.INVALID_PARAMS}

    sql = 'update _user set ? where _userID = ?'
    param = [sets, req.token._userID]

    pool.query sql, param, (err, result)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

      sql = 'select * from _user where _userID = ?'
      param = [req.token._userID]
      pool.query sql, param, (err, _user)->
        payload =
          _userID:    _user[0]['_userID']
          _userName:  _user[0]['_userName']
          _class:     _user[0]['_class']

        token = tms.jwt.sign payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC}

        unless token then return res.status(500).json {data: RCODE.SERVER_ERROR}
        tms.addBlacklist req.token
        delete req.token
        return res.json {data: token}


##################################################
# REST API
##################################################
user.post '/', tms.verifyToken
#user.post '/', acl.allowManager
user.post '/', (req, res)->
  unless req.body._userID     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._password   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._userName   then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._mobile     then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._birthdate  then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._sex        then return res.status(400).json {data: RCODE.INVALID_PARAMS}
  unless req.body._class      then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _user where _userID = ?'
  param = [req.body._userID]
  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length > 0 then return res.status(400).json {data: RCODE.USERNAME_EXISTS}

    sql = 'insert into _user set ?'
    param =
      _userID:    req.body._userID
      _password:  req.body._password
      _userName:  req.body._userName
      _mobile:    req.body._mobile
      _birthdate: req.body._birthdate
      _sex:       req.body._sex
      _class:     req.body._class
      _state:     USTATE.READY

    pool.query sql, param, (err, result)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

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
      param = [req.body._userID]
      pool.query sql, param, (err, inserted)->
        return res.json {data: inserted[0]}


user.get '/', tms.verifyToken
user.get '/', (req, res)->
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


user.get '/:_userID', tms.verifyToken
user.get '/:_userID', (req, res)->
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
    if _user[0]._isResigned then return res.status(400).json {data: RCODE.INVALID_USER_INFO}

    return res.json {data: _user[0]}


user.put '/:_userID', tms.verifyToken
#user.put '/:_userID', acl.allowManager
#user.put '/:_userID', verifyReq
user.put '/:_userID', (req, res)->
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


user.delete '/:_userID', tms.verifyToken
#user.delete '/:_userID', acl.allowManager
user.delete '/:_userID', (req, res)->
  unless req.params._userID  then return res.status(400).json {data: RCODE.INVALID_PARAMS}

  sql = 'select * from _user where _userID = ?'
  param = [req.params._userID]
  pool.query sql, param, (err, _user)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
    if _user.length < 1 then return res.status(400).json {data: RCODE.NO_RESULT}
    if JSON.parse(_user[0]['_isResigned']) then return res.status(400).json {data: RCODE.USER_RESIGNED}

    sql = 'update _user set _isResigned = ?, _deletedAt = ? where _userID = ?'
    param = [true, new Date(), req.token._userID]
    pool.query sql, param, (err, result)->
      if err then return res.status(500).json {data: RCODE.SERVER_ERROR}

      return res.json {data: RCODE.DELETE_SUCCEED}


module.exports = user