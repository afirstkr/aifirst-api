'use strict'

acl = {}

######################################################################
# middleware
######################################################################
acl.allowManager = (req, res, next) ->
  switch req.token._class
    when UCLASS.ADMIN   then return next()
    when UCLASS.VIP     then return next()
    when UCLASS.MANAGER then return next()
    when UCLASS.LEADER  then return res.status(400).json {data: RCODE.INVALID_PERMISSION}
    when UCLASS.MEMBER  then return res.status(400).json {data: RCODE.INVALID_PERMISSION}
    else
      return res.status(400).json {data: RCODE.INVALID_PERMISSION}

module.exports = acl