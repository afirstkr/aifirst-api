`use strict`

let user      = require(`express`).Router()
let validator = require(`validator`)
let tms       = require(`../helper/tms`)
let acl       = require(`../helper/acl`)

//////////////////////////////////////////////////
// logic condition validator
//////////////////////////////////////////////////
verifyReq = (req, res, next)=>{
  if ((req.method === `PUT`) && (req.body._TEST_PARAM === TEST_CONDITION))
    return log(`CHANGE ANY CONDITION HERE`)
  else
    return next()
 }


//////////////////////////////////////////////////
// HELPER API
//////////////////////////////////////////////////
user.get(`/helper/stateGroup`, tms.verifyToken)
user.get(`/helper/stateGroup`, (req, res)=>{
  if (!req.query._stateGroup) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  let sql = `
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
    `

  let where = ``
  let orderBy = ` order by _createdAt desc`

  if (req.query._stateGroup === USTATE_GROUP.HIRED) {
    where = ` where _state = 'WORK' or _state = 'OFF' or _state = 'EARLY_OFF' or _state = 'SICK_OFF' or _state = 'HIRED' `
  }
  else if (req.query._stateGroup === USTATE_GROUP.NO_HIRED)
    where = ` where _state = 'CONFIRM_REQUIRED' or _state = 'READY' `
  else if (req.query._stateGroup === USTATE_GROUP.LEAVE)
    where = ` where _state = 'LEAVE' `
  else
    return res.status(400).json({data: RCODE.INVALID_PARAMS})

  log(`sql =`, sql + where + orderBy)

  return pool.query(sql + where + orderBy, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length < 1) return res.json({data: RCODE.NO_RESULT})
    else return res.json({data: _user})
  })
})

user.get(`/helper/isExistsMobile`, tms.verifyToken)
user.get(`/helper/isExistsMobile`, (req, res)=>{
  if (!req.query._mobile) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  let sql = `select * from _user where _mobile = ?`
  let param = [req.query._mobile]

  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length > 0) return res.json({data: true})
    else return res.json({data: false})
  })
})


user.get(`/helper/hiredUserList`, tms.verifyToken)
user.get(`/helper/hiredUserList`, (req, res)=>{
  let sql = `
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
    `

  return pool.query(sql, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
    return res.json({data: _user})
  })
})


user.get(`/helper/stateReportWithManager`, tms.verifyToken)
user.get(`/helper/stateReportWithManager`, (req, res)=>{
  let sql = `
    select
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and (_state='WORK' or _state='OFF' or _state='SICK_OFF' or _state='EARLY_OFF')) as _total,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='WORK') as _work,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='OFF') as _off,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='SICK_OFF') as _sickOff,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _state='EARLY_OFF') as _earlyOff
    `

  return pool.query(sql, (err, result)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (result.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
    return res.json({data: result[0]})
  })
})

user.get(`/helper/stateReportWithoutManager`, tms.verifyToken)
user.get(`/helper/stateReportWithoutManager`, (req, res)=>{
  let sql = `
    select
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and (_state='WORK' or _state='OFF' or _state='SICK_OFF' or _state='EARLY_OFF')) as _total,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='WORK') as _work,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='OFF') as _off,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='SICK_OFF') as _sickOff,
      (select count(*) from _user where _class != 'VIP' and _class != 'ADMIN' and _class != 'MANAGER' and _state='EARLY_OFF') as _earlyOff
    `

  return pool.query(sql, (err, result)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (result.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
    return res.json({data: result[0]})
  })
})


user.post(`/helper/findMyID`, (req, res)=>{
  if (!req.body._userName) return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._mobile)   return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!validator.isMobilePhone(req.body._mobile, `ko-KR`)) return res.status(400).json({data: RCODE.INVALID_MOBILE_INFO})
  if (!req.body._code) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  // init mobile string
  req.body._mobile = req.body._mobile.replace(/-/g,"")

  let sql = `select * from _user where _userName = ? and _mobile = ?`
  let param = [req.body._userName, req.body._mobile]
  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

    // validate userName and mobile
    if (_user.length < 1) return res.status(400).json({data: RCODE.INVALID_USER_INFO})

    // validate otp and mobile
    return redis.get(req.body._mobile, (err, value)=> {
      if (err) {log(`err`, err);return res.status(500).json({data: RCODE.SERVER_ERROR})}
      if (!value) return res.status(500).json({data: RCODE.OTP_EXPIRED})

      let otp = JSON.parse(value)

      if (otp.code === req.body._code)
        return res.json({data: _user[0]._userID})
      else
        return res.status(400).json({data: RCODE.INVALID_OTP_CODE})
    })
  })
})


user.post(`/helper/resetMyPassword`, (req, res)=>{
  if (!req.body._userID) return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._mobile) return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!validator.isMobilePhone(req.body._mobile, `ko-KR`)) return res.status(400).json({data: RCODE.INVALID_MOBILE_INFO})
  if (!req.body._code) return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._password) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  // init mobile string
  req.body._mobile = req.body._mobile.replace(/-/g,"")

  let sql = `select * from _user where _userID = ? and _mobile = ?`
  let param = [req.body._userID, req.body._mobile]
  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

    // validate userID and mobile
    if (_user.length < 1) return res.status(400).json({data: RCODE.INVALID_USER_INFO})

    // validate otp and mobile
    return redis.get(req.body._mobile, (err, value)=> {
      if (err) {log(`err`, err); return res.status(500).json({data: RCODE.SERVER_ERROR})}
      if (!value) return res.status(500).json({data: RCODE.OTP_EXPIRED})

      let otp = JSON.parse(value)

      if (otp.code === req.body._code) {
        let sets = {}
        sets._password = req.body._password
        sql = `update _user set ? where _userID = ?`
        param = [sets, req.body._userID]
        return pool.query(sql, param, (err, result)=>{
          if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

          return res.json({data: RCODE.RESET_MY_PW_SUCCEED})
        })
      }
      else
        return res.status(400).json({data: RCODE.INVALID_OTP_CODE})
    })
  })
})

//#################################################
// SPECIAL API
//#################################################
user.post(`/signup`, (req, res)=>{
  if (!req.body._id)             return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._body._password) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  let sql = `select * from _human where _id = ?`
  let param = [req.body._id]

  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length > 0) return res.status(400).json({data: RCODE.USERNAME_EXISTS})
    
    sql = `insert into _human set ?`
    param = { 
      _id: req.body._id,
      _class: HCLASS.MEMBER,
      _body: JSON.stringify(req.body._body)
    }
        
    log(param)
    return pool.query(sql, param, (err, result)=>{
      if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
      
      sql = `select * from _human where _id = ?`
      param = [req.body._id]
      return pool.query(sql, param, (err, inserted)=>{
        inserted[0]._body = JSON.parse(inserted[0]._body)
        return res.json({data: inserted[0]})
      })
    })
  })
})

user.post(`/login`, (req, res)=>{
  if (!req.body._id)   return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._body) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  // check user info
  let sql = `select * from _human where _id = ? and _body->"$._password" = ?`
  let param = [req.body._id, req.body._body._password]

  return pool.query(sql, param, (err, userInfo)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (userInfo.length < 1) return res.status(400).json({data: RCODE.INVALID_LOGIN_INFO})
    
    log(userInfo[0])
    let body = JSON.parse(userInfo[0]._body)
    let payload = {
      _id:        userInfo[0]._id,
      _class:     userInfo[0]._class,
      _name:      body._name
    }

    let token = tms.jwt.sign(payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC})
    if (!token) return res.status(500).json({data: RCODE.SERVER_ERROR})
    return res.json({data: token})
  })
})


user.post(`/logout`, tms.verifyToken)
user.post(`/logout`, (req, res)=>{
  tms.addBlacklist(req.token)
  delete req.token
  return res.json({data: RCODE.LOGOUT_SUCCEED})
})


user.get(`/me`, tms.verifyToken)
user.get(`/me`, (req, res)=> res.json({data: req.token}))

user.put(`/me`, tms.verifyToken)
//user.put `/me`, verifyReq
user.put(`/me`, (req, res)=>{
  let sql = `select * from _human where _id = ?`
  let param = [req.token._id]

  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length < 1) return res.status(400).json({data: RCODE.INVALID_TOKEN})
    if (JSON.parse(_user[0][`_isResigned`])) return res.status(400).json({data: RCODE.USER_RESIGNED})

    let sets = {}
    let where = {username: req.token._userID}

    if (req.body._userName)     sets._userName     = req.body._userName
    if (req.body._password)     sets._password     = req.body._password
    if (req.body._mobile)       sets._mobile       = req.body._mobile
    if (req.body._birthdate)    sets._birthdate    = req.body._birthdate
    if (req.body._sex)          sets._sex          = req.body._sex
    if (req.body._state)        sets._state        = req.body._state
    if (req.body._thumbnailURL) sets._thumbnailURL = req.body._thumbnailURL

    if (JSON.stringify(sets) === `{}`) return res.status(400).json({data: RCODE.INVALID_PARAMS})

    sql = `update _user set ? where _userID = ?`
    param = [sets, req.token._userID]

    return pool.query(sql, param, (err, result)=>{
      if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

      sql = `select * from _user where _userID = ?`
      param = [req.token._userID]
      return pool.query(sql, param, (err, _user)=>{
        let payload = {
          _userID:    _user[0][`_userID`],
          _userName:  _user[0][`_userName`],
          _class:     _user[0][`_class`]
        }

        let token = tms.jwt.sign(payload, TOKEN.SECRET, {expiresIn: TOKEN.EXPIRE_SEC})

        if (!token) return res.status(500).json({data: RCODE.SERVER_ERROR})
        tms.addBlacklist(req.token)
        delete req.token
        return res.json({data: token})
      })
    })
  })
})


//////////////////////////////////////////////////
// REST API
//////////////////////////////////////////////////
user.post(`/`, tms.verifyToken)
//user.post `/`, acl.allowManager
user.post(`/`, (req, res)=>{
  if (!req.body._userID)    return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._password)  return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._userName)  return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._mobile)    return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._birthdate) return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._sex)       return res.status(400).json({data: RCODE.INVALID_PARAMS})
  if (!req.body._class)     return res.status(400).json({data: RCODE.INVALID_PARAMS})

  let sql = `select * from _user where _userID = ?`
  let param = [req.body._userID]
  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length > 0) return res.status(400).json({data: RCODE.USERNAME_EXISTS})

    sql = `insert into _user set ?`
    param = {
      _userID:    req.body._userID,
      _password:  req.body._password,
      _userName:  req.body._userName,
      _mobile:    req.body._mobile,
      _birthdate: req.body._birthdate,
      _sex:       req.body._sex,
      _class:     req.body._class,
      _state:     USTATE.READY
    }

    return pool.query(sql, param, (err, result)=>{
      if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

      sql = `
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
        `
      param = [req.body._userID]
      return pool.query(sql, param, (err, inserted) => {
        return res.json({data: inserted[0]})
      })
    })
  })
})


user.get(`/`, tms.verifyToken)
user.get(`/`, (req, res)=>{
  // check offset & limit
  let _class, _state, sql
  if (req.query._offset &&
      req.query._limit &&
      req.query._orderBy &&
      req.query._isAsc &&
      req.query._isAllClass &&
      req.query._isAllState) {

    let ascDesc
    if (JSON.parse(req.query._isAsc)) ascDesc = `asc`
    else ascDesc = `desc` 

    if (JSON.parse(req.query._isAllClass)) _class = ``
    else _class = UCLASS.ADMIN

    if (JSON.parse(req.query._isAllState)) _state = ``
    else _state = USTATE.CONFIRM_REQUIRED

    sql = `
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
      `
    sql += ` where _class != '${_class}' and _state != '${_state}' order by _createdAt desc, ${req.query._orderBy} ${ascDesc} limit ?,?`

    let param = [Number(req.query._offset), Number(req.query._limit)]
    return pool.query(sql, param, (err, _user)=>{
      if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

      return  res.json({data: _user})
  })

  // check field searching
  } else if (req.query._userID ||
          req.query._userName ||
          req.query._mobile ||
          req.query._birthdate ||
          req.query._sex ||
          req.query._class ||
          req.query._state ||
          req.query._isAllClass ||
          req.query._isAllState ||
          req.query._createdAt ||
          req.query._updatedAt) {

    if (req.query._isAllClass && JSON.parse(req.query._isAllClass)) { _class = ``
    } else { _class = UCLASS.ADMIN }

    if (req.query._isAllState && JSON.parse(req.query._isAllState)) { _state = ``
    } else { _state = USTATE.CONFIRM_REQUIRED }

    sql = `
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
      `
    let where = ` where _class != '${_class}' and _state != '${_state}' `
    let orderBy = ` order by _createdAt desc`

    if (req.query._userID     && (req.query._userID !== ``))    where += ` and _userID    =    '${req.query._userID}'`
    if (req.query._userName   && (req.query._userName !== ``))  where += ` and _userName  like '%${req.query._userName}%'`
    if (req.query._mobile     && (req.query._mobile !== ``))    where += ` and _mobile    like '%${req.query._mobile}%'`
    if (req.query._birthdate  && (req.query._birthdate !== ``)) where += ` and _birthdate like '%${req.query._birthdate}%'` 
    if (req.query._sex        && (req.query._sex !== ``))       where += ` and _sex       =    '${req.query._sex}'` 
    if (req.query._class      && (req.query._class !== ``))     where += ` and _class     =    '${req.query._class}'` 
    if (req.query._state      && (req.query._state !== ``))     where += ` and _state     =    '${req.query._state}'` 
    if (req.query._createdAt  && (req.query._createdAt !== ``))  where += ` and _createdAt like '${req.query._createdAt}%'` 
    if (req.query._updatedAt  && (req.query._updatedAt !== ``))  where += ` and _updatedAt like '${req.query._updatedAt}%'` 

    return pool.query(sql + where + orderBy, (err, _user)=>{
      if (err)              return res.status(500).json({data: RCODE.SERVER_ERROR})
      if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
      return res.json({data: _user})
  })

  // take all
  } 
  else {
    sql = `
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
      `

    return pool.query(sql, (err, _user)=>{
      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}) }
      if (_user.length < 1) { return res.status(400).json({data: RCODE.NO_RESULT}) }
      return res.json({data: _user})
    })
  }
})


user.get(`/:_userID`, tms.verifyToken)
user.get(`/:_userID`, function(req, res){
  let sql = `
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
      _userID = ?\
    `
  let param = [req.params._userID]
  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
    if (JSON.parse(_user[0][`_isResigned`])) return res.status(400).json({data: RCODE.INVALID_USER_INFO})

    return res.json({data: _user[0]})
  })
})


user.put(`/:_userID`, tms.verifyToken)
//user.put(`/:_userID`, acl.allowManager)
//user.put(`/:_userID`, verifyReq)
user.put(`/:_userID`, (req, res)=>{
  if (!req.params._userID)  return res.status(400).json({data: RCODE.INVALID_PARAMS})

  let sql = `select * from _user where _userID = ?`
  let param = [req.params._userID]

  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
    if (JSON.parse(_user[0][`_isResigned`])) return res.status(400).json({data: RCODE.USER_RESIGNED})

    let sets = {}

    if (req.body._password)     sets._password     = req.body._password
    if (req.body._userName)    sets._userName     = req.body._userName
    if (req.body._mobile)       sets._mobile       = req.body._mobile
    if (req.body._birthdate)    sets._birthdate    = req.body._birthdate
    if (req.body._sex)          sets._sex          = req.body._sex 
    if (req.body._class)        sets._class        = req.body._class 
    if (req.body._state)        sets._state        = req.body._state 
    if (req.body._thumbnailURL) sets._thumbnailURL = req.body._thumbnailURL 

    if (JSON.stringify(sets) === `{}`) return res.status(400).json({data: RCODE.INVALID_PARAMS}) 

    sql = `update _user set ? where _userID = ?`
    param = [sets, req.params._userID]
    return pool.query(sql, param, (err, result)=>{
      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}) }

      sets._userID = req.params._userID
      return res.json({data: sets})
    })
  })
})


user.delete(`/:_userID`, tms.verifyToken)
//user.delete(`/:_userID`, acl.allowManager)
user.delete(`/:_userID`, (req, res)=>{
  if (!req.params._userID) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  let sql = `select * from _user where _userID = ?`
  let param = [req.params._userID]
  return pool.query(sql, param, (err, _user)=>{
    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
    if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
    if (JSON.parse(_user[0][`_isResigned`])) return res.status(400).json({data: RCODE.USER_RESIGNED})

    sql = `update _user set _isResigned = ?, _deletedAt = ? where _userID = ?`
    param = [true, new Date(), req.params._userID]
    return pool.query(sql, param, (err, result)=>{
      if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

      return res.json({data: RCODE.DELETE_SUCCEED})
    })
  })
})


module.exports = user