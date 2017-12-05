`use strict`

let acl = {}

//////////////////////////////////////////////////
// middleware
//////////////////////////////////////////////////
acl.allowManager = (req, res, next)=>{
  switch (req.token._class) {
    case UCLASS.ADMIN:     return next()
    case UCLASS.VIP:       return next()
    case UCLASS.MANAGER:   return next()
    case UCLASS.LEADER:    return res.status(400).json({data: RCODE.INVALID_PERMISSION})
    case UCLASS.MEMBER:    return res.status(400).json({data: RCODE.INVALID_PERMISSION})
    default:
      return res.status(400).json({data: RCODE.INVALID_PERMISSION})
  }
}

module.exports = acl