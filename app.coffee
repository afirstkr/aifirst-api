'use strict'

# init express
http        = require 'http'
helmet      = require 'helmet'
express     = require 'express'
bodyParser  = require 'body-parser'
cors        = require 'cors'
redis       = require 'then-redis'
mysql       = require 'promise-mysql'
app         = express()

# init statics
require './helper/local'
require './helper/global'


# init database
log '================================================================================'
log 'init database at ' + MYSQL.HOST + ':'+ MYSQL.PORT
connectionConfig =
  host:MYSQL.HOST
  user:MYSQL.USER
  password:MYSQL.PASSWORD
  database:MYSQL.DATABASE
  multipleStatements: true

global.pool = mysql.createPool connectionConfig


# init redis
log 'init token cache at ' + REDIS.HOST + ':' + REDIS.PORT
global.redis  = redis.createClient {host: REDIS.HOST, port: REDIS.PORT, password: REDIS.PASSWORD}


# init middleware
app.use helmet()
app.use bodyParser.json()
app.use bodyParser.urlencoded {extended:true}
app.use cors()


# init router
app.use '/auth',  require './endpoint/auth'
app.use '/user',  require './endpoint/user'
app.use '/image', require './endpoint/image'
app.use '/post',  require './endpoint/post'


# start app
server = http.createServer app
server.listen APP.PORT, ->
  log 'AI FIRST Web Service Startup at ' + APP.URL
