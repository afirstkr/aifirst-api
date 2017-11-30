'use strict'

module.exports = (req, res, next)->
  sql = 'insert into _event set ?'
  param =
    _id:          req.method + req.url
    _class:       ECLASS.EVENT_CLASS_01
    _body:        JSON.stringify(req.body)

  pool.query sql, param, (err, result)->
    if err then return res.status(500).json {data: RCODE.SERVER_ERROR}
  next()