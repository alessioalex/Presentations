twitter = require 'ntwitter'
fs = require 'fs'
colors = require 'colors'
EventEmitter = require('events').EventEmitter
TweetEmitter = new EventEmitter()
MemoryMonitor = require './memoryMonitor/MemoryMonitor'
util = require 'util'
key = 'abcd'
log = console.log

fs.readFile 'config.json', 'UTF-8', (err, content) ->
  if err then throw err
  runIt JSON.parse(content)

appMemUsg = new MemoryMonitor('Tweet Broadcaster')

# Inter-process communication using a UNIX socket {
conn = require('net').createServer((socket) ->
  # new connection
  loggedIn = false

  TweetEmitter.on 'tweet', (tweet) ->
    # this can be optimized by storing the sockets in an array and removing
    # them on connection closed
    if socket.writable and loggedIn then socket.write tweet

  socket.on 'data', (data) ->
    # client must provide correct passphrase
    if data.toString() is key
      loggedIn = true
    # else disconnect him
    else
      socket.end 'bye'

  socket.on 'end', (data) ->
    # connection closed

).listen(process.cwd() + '/twit.sock')
# uncomment below to change it to a normal TCP server that listens on port 4000
# ).listen 4000
# }

# Streaming twitter content {
isRetweet = (tweet) ->
  tweet.retweeted or
  tweet.retweeted_status or
  tweet.text.toLowerCase().indexOf("rt ") > -1 or
  tweet.text.toLowerCase().indexOf(" rt ") > -1

streamByPhrase = (twit, searchTerms) ->
  log "Streaming: #{searchTerms}".yellow

  twit.stream 'user', track: searchTerms, (stream) ->

    stream.on 'data', (data) ->
      if !data.text
        # log "Not a real tweet here: #{JSON.stringify(data)}".red
      else if not isRetweet(data)
        log "#{data.user.name}".green + " (#{data.user.url})".yellow + " said: #{data.text}".cyan
        TweetEmitter.emit 'tweet', JSON.stringify(data)

    stream.on 'end', (response) ->
      # Handle a disconnection
      throw new Error "Twitter stream disconnected"

    stream.on 'destroy', (response) ->
      # Handle a 'silent' disconnection from Twitter, no end/error event fired
      throw new Error "Silent disconnection from Twitter"
# }

# Boot function {
runIt = (config) ->

  twit = new twitter
    consumer_key        : config.consumer_key
    consumer_secret     : config.consumer_secret
    access_token_key    : config.access_token_key
    access_token_secret : config.access_token_secret

  if !process.argv[2]
    throw new Error('Please provide the search term(s)')
  else
    # trim every search term
    searchTerms = process.argv[2].split(',').map (item) ->
      return item.trim()
    streamByPhrase twit, searchTerms
# }

# coffee tweet_broadcaster.coffee "iphone, nodejs"
