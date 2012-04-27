net    = require 'net'
log    = console.log
colors = require 'colors'
util   = require 'util'
EventEmitter = require('events').EventEmitter

class MessageBus
  constructor: (opts) ->
    @debug = false
    if opts?.debug
      @debug = opts?.debug
    @_serverUp = false
    @_sid = 0

  util.inherits MessageBus, EventEmitter

  send: (msg, from = 'server') ->
    @emit "#{from}Msg", msg

  startServer: ->
    @server = net.createServer (socket) =>
      socket_id = @_sid + 1
      @_sid++

      @on 'serverMsg', (msg, socket_id) =>
        @log 'serverMsg', msg
        socket.write JSON.stringify(msg) if socket.writable

      socket.on 'data', (data) =>
        data = data.toString().trim()
        @log "Server received >> " + data + "."
        if data is 'ls'
          @log 'emitting serverLs event'
          @emit 'serverLs', socket_id

      socket.on 'end', (data) ->
        # connection closed

    @server.on 'error', (err) =>
      @log 'MessageBus startServer error:'.red
      @log err
      if err.code is 'EADDRINUSE'
        @log 'Address in use, retrying...'
        process.nextTick =>
          @_bindPort()

    @_bindPort()

  _bindPort: ->
    return false if @_serverUp
    @server.listen =>
      log "MessageBus server up on: ", @server.address()
      @_serverUp = true
      @emit 'serverUp', @server.address()

  startClient: (port, host, callback = null) ->
    @client = net.createConnection port, host

    @client.setEncoding 'utf8'

    @client.on 'connect', =>
      @on 'clientMsg', (msg) ->
        @client.write msg
      callback() if callback isnt null

    @client.on 'data', (data) =>
      data = data.toString().trim()

      @log 'Client received: '
      @log data

      try
        data = JSON.parse data
        @log 'Client decoded data: '
        @log data
        @emit 'clientData', data
      catch err

    @client.on 'close', (data) =>
      @log 'Client connection closed'.red
      setTimeout =>
        @log 'Reconnecting to server..'.yellow
        @client.connect port
      , 1500

    @client.on 'error', (data) =>
      @log 'Client could not connect ...'.red

  log: (data) ->
    if @debug is true then log data

module.exports = MessageBus
