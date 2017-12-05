`use strict`

let jwt    = require(`jsonwebtoken`)
let moment = require(`moment`)
let tms    = {}

//////////////////////////////////////////////////
// middleware
//////////////////////////////////////////////////
tms.verifyToken = (req, res, next)=>{
  let token = req.headers.authorization
  if (!token) { return res.status(400).json({data: RCODE.INVALID_TOKEN}) }

  token = token.split(` `)
  if (!token) { return res.status(400).json({data: RCODE.INVALID_TOKEN}) }
  if (token[0].toUpperCase() !== TOKEN.TYPE) { return res.status(400).json({data: RCODE.INVALID_TOKEN}) }
  
  // verify token
  jwt.verify(token[1], TOKEN.SECRET, (err, decoded)=>{
    if (err) {
      if (err.name.toUpperCase() === `TOKENEXPIREDERROR`) { return res.status(400).json({data: RCODE.TOKEN_EXPIRED}) }
      return res.status(400).json({data: RCODE.INVALID_TOKEN})
    }

    // check blacklist token
    redis.get(token[1], (err, value)=>{
      if (err)   return res.status(400).json({data: RCODE.INVALID_TOKEN})
      if (value) return res.status(400).json({data: RCODE.INVALID_TOKEN})

      req.token = decoded
      req.token._raw = token[1]
      next()
    })
  })
}


//////////////////////////////////////////////////
// jwt, blacklist
//////////////////////////////////////////////////
tms.jwt = jwt

tms.addBlacklist = (token)=>{
  if (!token) return log(RCODE.INVALID_TOKEN)
  let now = Math.round(new Date() / 1000)
  let delta = token.exp - now

  let iat = moment.unix(token.iat).format(`YYYY-MM-DD a hh:mm:ss`)
  let exp = moment.unix(token.exp).format(`YYYY-MM-DD a hh:mm:ss`)
  redis.set(token._raw, JSON.stringify({iat, exp}))
  return redis.expire(token._raw, delta)
}

module.exports = tms