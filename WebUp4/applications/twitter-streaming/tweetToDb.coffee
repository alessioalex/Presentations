MemoryMonitor = require './memoryMonitor/MemoryMonitor'
EventEmitter = require('events').EventEmitter
TweetEmitter = new EventEmitter()
log = console.log

# MongoDB vars {
Db = require('mongodb').Db
Server = require('mongodb').Server
db_port = 27017
db_host = 'localhost'
# }

# initiate connection to tweet broadcaster
require('./tweetListener')(TweetEmitter)

appMemUsg = new MemoryMonitor('Tweet to Database')

nr = 0

db = new Db('tweets_db', new Server(db_host, db_port, {}), native_parser: false)
db.open (err, db) ->
  if err then throw err
  db.collection 'tweets', (err, collection) ->
    collection.createIndex ["meta", ['id', 1]], (err, indexName) ->
      if err then throw err
      TweetEmitter.on 'tweet', (tweet) ->
        log "##{++nr}" + ": #{tweet.user.name}".green + " (#{tweet.user.url})".yellow + " said: #{tweet.text}".cyan
        collection.insert tweet, (err, docs) ->
          if err then throw err

