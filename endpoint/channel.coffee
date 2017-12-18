'use strict';

express   = require 'express'
validator = require 'validator'
tms       = require '../helper/tms'
acl       = require '../helper/acl'
channel   = express.Router()

######################################################################
# REST API
######################################################################
#channel.post '/', tms.verifyToken
#channel.post '/', acl.allowManager
#channel.post '/', (req, res) ->
#  unless req.body._id          return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#  if (!req.body._body) {       return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#  if (!req.body._class) {      return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#
#  let sql = 'insert into _channel set ?';
#  let param = {
#    _id: req.body._id,
#    _class: CCLASS.POST,
#    _from: JSON.stringify(req.body._from),
#    _to: JSON.stringify(req.body._to),
#    _body: JSON.stringify(req.body._body)
#  };
#
#  return pool.query(sql, param, function(err, result){
#    if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#
#    sql = 'select * from _channel where _id = ?';
#    param = [req.body._id];
#    return pool.query(sql, param, function(err, inserted){
#      inserted[0]._from = JSON.parse(inserted[0]._from);
#      inserted[0]._to   = JSON.parse(inserted[0]._to);
#      inserted[0]._body = JSON.parse(inserted[0]._body);
#      return res.json({data: inserted[0]});
#  });
#});
#});

#// channel.get '/list', tms.verifyToken
#//user.post '/list', acl.allowManager
#channel.get('/list/:_from', function(req, res){
#  if (!req.params._from) {       return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#
#  const sql = 'select * from _channel where JSON_CONTAINS(_from, ?)';
#  const param = [JSON.stringify(req.params._from)];
#  return pool.query(sql, param, (err, list)=> res.json({data: list}));
#});
#
#channel.get('/', tms.verifyToken);
#channel.get('/', function(req, res){
#  // check offset & limit
#  let _class, _state, sql;
#  if  (req.query._offset &&
#      req.query._limit &&
#      req.query._orderBy &&
#      req.query._isAsc &&
#      req.query._isAllClass &&
#      req.query._isAllState) {
#
#    let ascDesc;
#    if (JSON.parse(req.query._isAsc)) { ascDesc = 'asc';
#    } else { ascDesc = 'desc'; }
#
#    if (JSON.parse(req.query._isAllClass)) { _class = '';
#    } else { _class = UCLASS.ADMIN; }
#
#    if (JSON.parse(req.query._isAllState)) { _state = '';
#    } else { _state = USTATE.CONFIRM_REQUIRED; }
#
#    sql = 'select * from _channel';
#    sql += ' where _class != '${_class}' and _state != '${_state}' order by _createdAt desc, ${req.query._orderBy} ${ascDesc} limit ?,?';
#
#    const param = [Number(req.query._offset), Number(req.query._limit)];
#    return pool.query(sql, param, function(err, _user){
#      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#
#      return  res.json({data: _user});
#  });
#
#  // check field searching
#  } else if (req.query._userID ||
#          req.query._userName ||
#          req.query._mobile ||
#          req.query._birthdate ||
#          req.query._sex ||
#          req.query._class ||
#          req.query._state ||
#          req.query._isAllClass ||
#          req.query._isAllState ||
#          req.query._createdAt ||
#          req.query._updatedAt) {
#
#    if (req.query._isAllClass && JSON.parse(req.query._isAllClass)) { _class = '';
#    } else { _class = UCLASS.ADMIN; }
#
#    if (req.query._isAllState && JSON.parse(req.query._isAllState)) { _state = '';
#    } else { _state = USTATE.CONFIRM_REQUIRED; }
#
#    sql = '\
#select
#  _user._userID,
#  _user._userName,
#  _user._mobile,
#  _user._birthdate,
#  _user._sex,
#  _user._class,
#  _user._state,
#  _user._thumbnailURL,
#  _user._isResigned,
#  _user._createdAt,
#  _user._updatedAt,
#  _user._deletedAt
#from
#  _user\
#';
#    let where = ' where _class != '${_class}' and _state != '${_state}' ';
#    const orderBy = ' order by _createdAt desc';
#
#    if (req.query._userID     && (req.query._userID !== '')) {     where += ' and _userID    =     '${req.query._userID}''; }
#    if (req.query._userName   && (req.query._userName !== '')) {   where += ' and _userName  like '%${req.query._userName}%''; }
#    if (req.query._mobile     && (req.query._mobile !== '')) {     where += ' and _mobile    like '%${req.query._mobile}%''; }
#    if (req.query._birthdate  && (req.query._birthdate !== '')) {  where += ' and _birthdate like '%${req.query._birthdate}%''; }
#    if (req.query._sex        && (req.query._sex !== '')) {        where += ' and _sex       =     '${req.query._sex}''; }
#    if (req.query._class      && (req.query._class !== '')) {      where += ' and _class     =     '${req.query._class}''; }
#    if (req.query._state      && (req.query._state !== '')) {      where += ' and _state     =     '${req.query._state}''; }
#    if (req.query._createdAt && (req.query._createdAt !== '')) {   where += ' and _createdAt like  '${req.query._createdAt}%''; }
#    if (req.query._updatedAt && (req.query._updatedAt !== '')) {   where += ' and _updatedAt like  '${req.query._updatedAt}%''; }
#
#    return pool.query(sql + where + orderBy, function(err, _user){
#      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#      if (_user.length < 1) { return res.status(400).json({data: RCODE.NO_RESULT}); }
#      return res.json({data: _user});
#  });
#
#  // take all
#  } else {
#    sql = '\
#select
#  _user._userID,
#  _user._userName,
#  _user._mobile,
#  _user._birthdate,
#  _user._sex,
#  _user._class,
#  _user._state,
#  _user._thumbnailURL,
#  _user._isResigned,
#  _user._createdAt,
#  _user._updatedAt,
#  _user._deletedAt
#from
#  _user
#order by _createdAt desc\
#';
#
#    return pool.query(sql, function(err, _user){
#      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#      if (_user.length < 1) { return res.status(400).json({data: RCODE.NO_RESULT}); }
#      return res.json({data: _user});
#  });
#  }
#});
#
#
#channel.get('/:_userID', tms.verifyToken);
#channel.get('/:_userID', function(req, res){
#  const sql = '\
#select
#  _user._userID,
#  _user._userName,
#  _user._mobile,
#  _user._birthdate,
#  _user._sex,
#  _user._class,
#  _user._state,
#  _user._thumbnailURL,
#  _user._isResigned,
#  _user._createdAt,
#  _user._updatedAt,
#  _user._deletedAt
#from
#  _user
#where
#  _userID = ?\
#';
#  const param = [req.params._userID];
#  return pool.query(sql, param, function(err, _user){
#    if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#    if (_user.length < 1) { return res.status(400).json({data: RCODE.NO_RESULT}); }
#    if (JSON.parse(_user[0]['_isResigned'])) { return res.status(400).json({data: RCODE.INVALID_USER_INFO}); }
#
#    return res.json({data: _user[0]});
#});
#});
#
#
#channel.put('/:_userID', tms.verifyToken);
#//channel.put '/:_userID', acl.allowManager
#//channel.put '/:_userID', verifyReq
#channel.put('/:_userID', function(req, res){
#  if (!req.params._userID) {  return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#
#  let sql = 'select * from _user where _userID = ?';
#  let param = [req.params._userID];
#
#  return pool.query(sql, param, function(err, _user){
#    if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#    if (_user.length < 1) { return res.status(400).json({data: RCODE.NO_RESULT}); }
#    if (JSON.parse(_user[0]['_isResigned'])) { return res.status(400).json({data: RCODE.USER_RESIGNED}); }
#
#    const sets = {};
#
#    if (req.body._password) {     sets._password     = req.body._password; }
#    if (req.body._userName) {     sets._userName     = req.body._userName; }
#    if (req.body._mobile) {       sets._mobile       = req.body._mobile; }
#    if (req.body._birthdate) {    sets._birthdate    = req.body._birthdate; }
#    if (req.body._sex) {          sets._sex          = req.body._sex; }
#    if (req.body._class) {        sets._class        = req.body._class; }
#    if (req.body._state) {        sets._state        = req.body._state; }
#    if (req.body._thumbnailURL) { sets._thumbnailURL = req.body._thumbnailURL; }
#
#    if (JSON.stringify(sets) === '{}') { return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#
#    sql = 'update _user set ? where _userID = ?';
#    param = [sets, req.params._userID];
#    return pool.query(sql, param, function(err, result){
#      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#
#      sets._userID = req.params._userID;
#      return res.json({data: sets});
#  });
#});
#});
#
#
#channel.delete('/:_userID', tms.verifyToken);
#//channel.delete '/:_userID', acl.allowManager
#channel.delete('/:_userID', function(req, res){
#  if (!req.params._userID) {  return res.status(400).json({data: RCODE.INVALID_PARAMS}); }
#
#  let sql = 'select * from _user where _userID = ?';
#  let param = [req.params._userID];
#  return pool.query(sql, param, function(err, _user){
#    if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#    if (_user.length < 1) { return res.status(400).json({data: RCODE.NO_RESULT}); }
#    if (JSON.parse(_user[0]['_isResigned'])) { return res.status(400).json({data: RCODE.USER_RESIGNED}); }
#
#    sql = 'update _user set _isResigned = ?, _deletedAt = ? where _userID = ?';
#    param = [true, new Date(), req.params._userID];
#    return pool.query(sql, param, function(err, result){
#      if (err) { return res.status(500).json({data: RCODE.SERVER_ERROR}); }
#
#      return res.json({data: RCODE.DELETE_SUCCEED});
#  });
#});
#});


module.exports = channel;