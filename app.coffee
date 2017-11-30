'use strict'


# init express
http        = require 'http'
fs          = require 'fs'
helmet      = require 'helmet'
app         = (require 'express')()
bodyParser  = require 'body-parser'
cors        = require 'cors'
redis       = require 'redis'
mysql       = require 'mysql'


# init statics
require './helper/local'
require './helper/global'


# init database
log '================================================================================'
log "init database at #{MYSQL.HOST}:#{MYSQL.PORT}"
connectionConfig =
  host:MYSQL.HOST
  user:MYSQL.USER
  password:MYSQL.PASSWORD
  database:MYSQL.DATABASE
  multipleStatements: true
global.pool = mysql.createPool connectionConfig


# init redis
log "init token cache at #{REDIS.HOST}:#{REDIS.PORT}"
global.redis  = redis.createClient {host: REDIS.HOST, port: REDIS.PORT, password: REDIS.PASSWORD}


# init middleware
app.use helmet()
app.use bodyParser.json()
app.use bodyParser.urlencoded({extended:true})
app.use cors()


# init bots

eventBot = require './bots/event'
app.use eventBot

# init router
app.use '/user',          require './endpoint/user'
app.use '/channel',       require './endpoint/channel'

# start app
server = http.createServer(app);
server.listen APP.PORT, ()->
  log 'AI FIRST Web Service Startup'

# socket io
# io = require('socket.io')(server)
# io.on 'connection', (socket)->
#   socket.on '_event', (_event)->
#     humanBot(_event)
#     pointBot(_event)
#     boardBot(_event)

#   socket.on 'disconnect', ()->
#     log 'disconnected'