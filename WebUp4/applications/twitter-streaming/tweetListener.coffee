net = require 'net'
colors = require 'colors'
key = 'abcd'
log = console.log

module.exports = (TweetEmitter) ->
  conn = net.createConnection(process.cwd() + '/twit.sock')
  # uncomment below for TCP connection to port 4000 instead of a Unix Socket
  # conn = net.createConnection 4000

  conn.setEncoding 'utf8'

  conn.on 'connect', ->
    log '::: Connected to Tweet Server '.green
    conn.write key

  conn.on 'data', (tweet) ->
    try
      tweet = JSON.parse tweet
      TweetEmitter.emit 'tweet', tweet
    catch err

  conn.on 'close', (data) ->
    log '::: Connection closed'.red
    setTimeout ->
      log '::: Reconnecting to server..'.yellow
      conn.connect(process.cwd() + '/twit.sock')
    , 1500

  conn.on 'error', (data) ->
    log '::: Could not connect to the Tweet Server'.red
