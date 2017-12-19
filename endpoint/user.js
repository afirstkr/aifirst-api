// Generated by CoffeeScript 2.1.0
(function() {
  'use strict';
  var acl, express, tms, user;

  express = require('express');

  tms = require('../helper/tms');

  acl = require('../helper/acl');

  user = express.Router();

  //#####################################################################
  // REST API
  //#####################################################################
  user.post('/', tms.verifyToken);

  user.post('/', acl.allowManager);

  user.post('/', async function(req, res) {
    var err, param, sql;
    if (!req.body.email) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    if (!req.body.password) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    if (!req.body.userName) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    if (!req.body.mobile) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    try {
      sql = 'select * from user where email = ?';
      param = [req.body.email];
      user = (await pool.query(sql, param));
      if (user.length > 0) {
        return res.status(400).json({
          data: RCODE.USERNAME_EXISTS
        });
      }
      sql = 'insert into user set ?';
      param = {
        email: req.body.email,
        password: req.body.password,
        userName: req.body.userName,
        mobile: req.body.mobile
      };
      await pool.query(sql, param);
      sql = 'select * from user where email = ?';
      param = [req.body.email];
      user = (await pool.query(sql, param));
      return res.json({
        data: user[0]
      });
    } catch (error) {
      err = error;
      log('err=', err);
      return res.status(500).json({
        data: RCODE.SERVER_ERROR
      });
    }
  });

  user.get('/', tms.verifyToken);

  user.get('/', async function(req, res) {
    var err, offset, page, pages, param, result, size, sql, total;
    if (!req.query.page) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    if (!req.query.size) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    if (!req.query.preset) {
      return res.status(400).json({
        data: RCODE.INVALID_PARAMS
      });
    }
    try {
      switch (req.query.preset) {
        case QUERY.USER_DEFAULT:
          sql = 'select * from user where isRemoved=false order by createdAt desc limit ?,?';
          break;
        default:
          return res.status(400).json({
            data: RCODE.INVALID_PARAMS
          });
      }
      total = (await pool.query('select count(*) as total from user where isRemoved=false'));
      total = total[0].total;
      size = parseInt(req.query.size);
      page = parseInt(req.query.page);
      pages = Math.ceil(total / size);
      offset = (page - 1) * size;
      result = {
        meta: {
          total: total,
          pages: pages,
          size: size,
          page: req.query.page,
          offset: offset
        }
      };
      param = [offset, size];
      json.data = (await pool.query(sql, param));
      return res.status(200).json(result);
    } catch (error) {
      err = error;
      log('err=', err);
      return res.status(500).json({
        data: RCODE.SERVER_ERROR
      });
    }
  });

  user.get('/:email', tms.verifyToken);

  user.get('/:email', async function(req, res) {
    var err, param, sql;
    try {
      sql = 'select * from user where email=? and isRemoved=false';
      param = [req.params.email];
      user = (await pool.query(sql, param));
      if (user.length < 1) {
        return res.status(400).json({
          data: RCODE.NO_RESULT
        });
      }
      delete user[0].password;
      delete user[0].score;
      delete user[0].coin;
      return res.json({
        data: user[0]
      });
    } catch (error) {
      err = error;
      log('err=', err);
      return res.status(500).json({
        data: RCODE.SERVER_ERROR
      });
    }
  });

  user.put('/:email', tms.verifyToken);

  user.put('/:email', acl.allowManager);

  user.put('/:email', function(req, res) {
    return res.json({
      data: RCODE.TEST_SUCCEED
    });
  });

  //  if (!req.params._userID)  return res.status(400).json({data: RCODE.INVALID_PARAMS})

  //  let sql = 'select * from _user where _userID = ?'
  //  let param = [req.params._userID]

  //  return pool.query(sql, param, (err, _user)=>{
  //    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
  //    if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
  //    if (JSON.parse(_user[0]['_isResigned'])) return res.status(400).json({data: RCODE.USER_RESIGNED})

  //    let sets = {}

  //    if (req.body._password)     sets._password     = req.body._password
  //    if (req.body._userName)    sets._userName     = req.body._userName
  //    if (req.body._mobile)       sets._mobile       = req.body._mobile
  //    if (req.body._birthdate)    sets._birthdate    = req.body._birthdate
  //    if (req.body._sex)          sets._sex          = req.body._sex
  //    if (req.body._class)        sets._class        = req.body._class
  //    if (req.body._state)        sets._state        = req.body._state
  //    if (req.body._thumbnailURL) sets._thumbnailURL = req.body._thumbnailURL

  //    if (JSON.stringify(sets) === '{}') return res.status(400).json({data: RCODE.INVALID_PARAMS})

  //    sql = 'update _user set ? where _userID = ?'
  //    param = [sets, req.params._userID]
  //    return pool.query(sql, param, (err, result)=>{
  //      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}) }

  //      sets._userID = req.params._userID
  //      return res.json({data: sets})
  //    })
  //  })
  //})

  //user.delete('/:_userID', tms.verifyToken)
  //user.delete('/:_userID', acl.allowManager)
  //user.delete('/:_userID', (req, res)=>{
  //  if (!req.params._userID) return res.status(400).json({data: RCODE.INVALID_PARAMS})

  //  let sql = 'select * from _user where _userID = ?'
  //  let param = [req.params._userID]
  //  return pool.query(sql, param, (err, _user)=>{
  //    if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})
  //    if (_user.length < 1) return res.status(400).json({data: RCODE.NO_RESULT})
  //    if (JSON.parse(_user[0]['_isResigned'])) return res.status(400).json({data: RCODE.USER_RESIGNED})

  //    sql = 'update _user set _isResigned = ?, _deletedAt = ? where _userID = ?'
  //    param = [true, new Date(), req.params._userID]
  //    return pool.query(sql, param, (err, result)=>{
  //      if (err) return res.status(500).json({data: RCODE.SERVER_ERROR})

  //      return res.json({data: RCODE.DELETE_SUCCEED})
  //    })
  //  })
  //})
  module.exports = user;

}).call(this);

//# sourceMappingURL=user.js.map
