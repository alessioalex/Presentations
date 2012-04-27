util           = require 'util'
express        = require 'express'
connect        = require 'connect'
connectTimeout = require 'connect-timeout'
RedisStore     = require('connect-redis')(express)
io             = require 'socket.io'
EventEmitter   = require('events').EventEmitter
MemoryMonitor  = require './memoryMonitor/MemoryMonitor'
MemoryMaster   = require './memoryMonitor/MemoryMaster'
TweetEmitter   = new EventEmitter()
DbEmitter      = new EventEmitter()
MemoryEmitter  = new EventEmitter()

appMemMaster = new MemoryMaster({ interval: 2000 }, MemoryEmitter)
appMemUsg    = new MemoryMonitor('Tweet WebServer')

# Database stuff {
Db = require('mongodb').Db
Server = require('mongodb').Server
db_port = 27017
db_host = 'localhost'

db = new Db('tweets_db', new Server(db_host, db_port, {}), native_parser: false)
db.open (err, db) ->
  if err then throw err
  db.collection 'tweets', (err, collection) ->
    DbEmitter.on 'find100', (callback) ->
      collection.find({}, {limit: 100}, callback)
# }

app = express.createServer()
io  = io.listen app

# Socket.IO configs {
io.enable 'browser client minification' # send minified client
io.enable 'browser client etag'         # apply etag caching logic based on version number
io.enable 'browser client gzip'         # gzip the file
io.set 'log level', 1                   # reduce logging
io.set 'transports', [                  # enable all transports (optional if you want flashsocket)
    'websocket'
  , 'flashsocket'
  , 'htmlfile'
  , 'xhr-polling'
  , 'jsonp-polling'
]
# }

# Boilerplate {
app.configure ->
  app.use express.favicon()
  app.use express.static(__dirname + '/tweetWebServer/public')
  app.set 'views', __dirname + '/tweetWebServer/views'
  app.set 'view engine', 'jade'
  # Uncomment below if you don't want to have the same layout for every page
  # app.set 'view options', layout: false
  app.use express.bodyParser()
  app.use express.cookieParser()
  # The session middleware must always be after the cookieParser()
  # because it depends on it
  app.use express.session
    key    : 'webup.sid'
    store  : new RedisStore()
    secret : 'someRandomMumboJamboInHere'
    cookie :
      # session expires in 30 minutes
      # 30 * 60 * 1000 =
      maxAge: 1800000,

  # Middleware that overrides current method (for ex. POST) with
  # what's passed into the hidden variable _method (for ex: DELETE, PUT)
  # methodOverride must be after the bodyParser
  app.use express.methodOverride()
  # timeout the request after 60 seconds
  app.use connectTimeout time: 60000
  app.use express.csrf()

app.configure 'development', ->
  app.use express.errorHandler({ dumpExceptions: true })
  # html source indented properly for dev
  app.set 'view options'
    pretty: true
  # app.set 'db-url', 'dev-db-value'

app.configure 'production', ->
  app.use connect.compress({ level: 9, memLevel: 9 })
  # app.set 'db-url', 'production-db-value'

# Register dynamic view helpers
require('./tweetWebServer/helpers/dynamic')(app)
# } Boilerplate

# initiate connection to tweet broadcaster
require('./tweetListener')(TweetEmitter)

# Socket.IO magic {
io.of('/tweets').on 'connection', (socket) ->
  TweetEmitter.on 'tweet', (tweet) ->
    socket.emit 'tweet', tweet

io.of('/memory').on 'connection', (socket) ->
  MemoryEmitter.on 'memUsg', (data) ->
    socket.emit 'memUsg', data
# }

# Routes {
app.get '/', (req, res) ->
  res.render "index"

app.get '/allTweets', (req, res) ->
  res.render "allTweets"

app.get '/tweets.json', (req, res) ->
  DbEmitter.emit 'find100', (err, cursor) ->
    cursor.toArray (err, tweets) ->
      res.json tweets
# }

# Error handling {
NotFound = (msg) ->
  this.name = 'NotFound'
  Error.call this, msg
  Error.captureStackTrace this, arguments.callee

util.inherits NotFound, Error

app.get '/500', (req, res) ->
  throw new Error 'An expected error'

app.get '*', (req, res, next) ->
  req.url = '/404'
  next()

app.get '/404', (req, res) ->
  throw new NotFound

app.error (err, req, res, next) ->
  if err instanceof NotFound
    res.render '404.jade', status: 404
  else
    next err

if app.settings.env == 'production'
  app.error (err, req, res) ->
    res.render '500.jade',
      status: 500
      locals:
        error: err
# } Error handling

# Uncomment below for production usage
# NODE_ENV=production coffee server.coffee

unless module.parent
  app.listen 80
  console.log 'Express server listening on port %d, environment: %s', app.address().port, app.settings.env
