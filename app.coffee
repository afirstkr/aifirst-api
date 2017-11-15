'use strict'


# init express
https       = require 'https'
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


# init router
app.use '/user',        require './endpoint/user'


# start app
ssl =
  key:  fs.readFileSync SSL.KEY
  cert: fs.readFileSync SSL.CERT

server = https.createServer(ssl, app);
server.listen APP.SSL_PORT, ()->
  log 'AI FIRST Web Service Startup with SSL'
