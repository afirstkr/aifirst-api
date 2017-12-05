`use strict`


// init express
let http        = require(`http`)
let fs          = require(`fs`)
let helmet      = require(`helmet`)
let express     = require(`express`)
let bodyParser  = require(`body-parser`)
let cors        = require(`cors`)
let redis       = require(`redis`)
let mysql       = require(`mysql`)
let app         = express()

// init statics
require(`./helper/local`)
require(`./helper/global`)


// init database
log(`================================================================================`)
log(`init database at ${MYSQL.HOST}:${MYSQL.PORT}`)
let connectionConfig = {
  host:MYSQL.HOST,
  user:MYSQL.USER,
  password:MYSQL.PASSWORD,
  database:MYSQL.DATABASE,
  multipleStatements: true
}
global.pool = mysql.createPool(connectionConfig)


// init redis
log(`init token cache at ${REDIS.HOST}:${REDIS.PORT}`)
global.redis  = redis.createClient({host: REDIS.HOST, port: REDIS.PORT, password: REDIS.PASSWORD})


// init middleware
app.use(helmet())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended:true}))
app.use(cors())


// init router
app.use(`/user`,    require(`./endpoint/user`))
// app.use(`/channel`, require(`./endpoint/channel`))


// start app
let server = http.createServer(app)
server.listen(APP.PORT, ()=> log(`AI FIRST Web Service Startup at ${APP.HOST}:${APP.PORT}`))