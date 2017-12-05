`use strict`

let sprintf = require(`sprintf-js`)
let moment  = require(`moment`)
let otp     = {}

otp.makeOtp = ()=> {
  let ttl = 60 * 3
  let min = 1
  let max = 9999

  let now = Math.round(new Date() / 1000)
  let exp = now + ttl

  let newOTP = {}

  newOTP.code      = sprintf(`%04d`, Math.floor(Math.random() * max) + min)
  newOTP.ttl       = ttl
  newOTP.createdAt = moment.unix(now).format(`YYYY-MM-DD a hh:mm:ss`)
  newOTP.expiredAt = moment.unix(exp).format(`YYYY-MM-DD a hh:mm:ss`)

  return newOTP
}

module.exports = otp