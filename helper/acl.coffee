'use strict'

acl = {}

######################################################################
# middleware
######################################################################
acl.allowManager = (req, res, next) ->
  switch req.token.uclass
    when UCLASS.ADMIN then return next()
    when UCLASS.USER  then return res.status(400).json {data: RCODE.INVALID_PERMISSION}
    else
      return res.status(400).json {data: RCODE.INVALID_PERMISSION}

module.exports = acl