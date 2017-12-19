'use strict'

sprintf = require('sprintf-js').sprintf
moment  = require 'moment'
otp     = {}

otp.makeOtp = ->
  ttl = 60 * 3
  min = 1
  max = 9999

  now = Math.round(new Date() / 1000)
  exp = now + ttl

  newOTP = {}

  newOTP.code      = sprintf '%04d', Math.floor(Math.random() * max) + min
  newOTP.ttl       = ttl
  newOTP.createdAt = moment.unix(now).format 'YYYY-MM-DD a hh:mm:ss'
  newOTP.expiredAt = moment.unix(exp).format 'YYYY-MM-DD a hh:mm:ss'

  return newOTP


module.exports = otp