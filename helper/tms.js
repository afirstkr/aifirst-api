// Generated by CoffeeScript 2.1.0
(function() {
  'use strict';
  var jwt, moment, tms;

  jwt = require('jsonwebtoken');

  moment = require('moment');

  tms = {};

  //#####################################################################
  // middleware
  //#####################################################################
  tms.verifyToken = function(req, res, next) {
    var err, token;
    token = req.headers.authorization;
    if (!token) {
      return res.status(400).json({
        data: RCODE.INVALID_TOKEN
      });
    }
    try {
      token = token.split(' ');
      if (!token) {
        return res.status(400).json({
          data: RCODE.INVALID_TOKEN
        });
      }
      if (token[0].toUpperCase() !== TOKEN.TYPE) {
        return res.status(400).json({
          data: RCODE.INVALID_TOKEN
        });
      }
      // verify token
      jwt.verify(token[1], TOKEN.SECRET, async function(err, decoded) {
        var value;
        if (err) {
          if (err.name.toUpperCase() === 'TOKENEXPIREDERROR') {
            return res.status(400).json({
              data: RCODE.TOKEN_EXPIRED
            });
          }
          return res.status(400).json({
            data: RCODE.INVALID_TOKEN
          });
        }
        // check blacklist token
        value = (await redis.get(token[1]));
        if (value) {
          return res.status(400).json({
            data: RCODE.INVALID_TOKEN
          });
        }
        req.token = decoded;
        req.token.raw = token[1];
        return next();
      });
      return void 0;
    } catch (error) {
      err = error;
      log('err=', err);
      return res.status(500).json({
        data: RCODE.SERVER_ERROR
      });
    }
  };

  //#####################################################################
  // jwt, blacklist
  //#####################################################################
  tms.jwt = jwt;

  tms.addBlacklist = function(token) {
    var delta, exp, iat, now;
    if (!token) {
      return log(RCODE.INVALID_TOKEN);
    }
    now = Math.round(new Date() / 1000);
    delta = token.exp - now;
    iat = moment.unix(token.iat).format('YYYY-MM-DD a hh:mm:ss');
    exp = moment.unix(token.exp).format('YYYY-MM-DD a hh:mm:ss');
    redis.set(token.raw, JSON.stringify({iat, exp}));
    return redis.expire(token.raw, delta);
  };

  module.exports = tms;

}).call(this);

//# sourceMappingURL=tms.js.map
