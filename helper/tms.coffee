'use strict'

jwt    = require 'jsonwebtoken'
moment = require 'moment'
tms    = {}

######################################################################
# middleware
######################################################################
tms.verifyToken = (req, res, next) ->
  token = req.headers.authorization
  unless token then return res.status(400).json {data: RCODE.INVALID_TOKEN}

  try
    token = token.split ' '
    unless token then return res.status(400).json {data: RCODE.INVALID_TOKEN}
    if token[0].toUpperCase() isnt TOKEN.TYPE then return res.status(400).json {data: RCODE.INVALID_TOKEN}

    # verify token
    jwt.verify token[1], TOKEN.SECRET, (err, decoded) ->
      if err
        if err.name.toUpperCase() is 'TOKENEXPIREDERROR' then return res.status(400).json {data: RCODE.TOKEN_EXPIRED}
        return res.status(400).json {data: RCODE.INVALID_TOKEN}


      # check blacklist token
      value = await redis.get token[1]
      if value  then return res.status(400).json {data: RCODE.INVALID_TOKEN}

      req.token = decoded
      req.token._raw = token[1]
      next()
    undefined

  catch err
    log 'err=', err
    return res.status(500).json {data: RCODE.SERVER_ERROR}

######################################################################
# jwt, blacklist
######################################################################
tms.jwt = jwt

tms.addBlacklist = (token) ->
  unless token then return log RCODE.INVALID_TOKEN
  now = Math.round new Date() / 1000
  delta = token.exp - now

  iat = moment.unix(token.iat).format 'YYYY-MM-DD a hh:mm:ss'
  exp = moment.unix(token.exp).format 'YYYY-MM-DD a hh:mm:ss'
  redis.set token._raw, JSON.stringify {iat, exp}
  return redis.expire token._raw, delta


module.exports = tms