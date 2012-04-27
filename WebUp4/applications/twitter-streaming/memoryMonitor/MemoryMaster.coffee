net = require 'net'
EventEmitter = require('events').EventEmitter
colors = require 'colors'
log = require './logger'
serverPort = 5000

class MemoryMaster

  constructor: (options, @emitter = new EventEmitter()) ->
    @interval = options.interval
    @debug = options.debug
    @createServer()

  createServer: ->
    server = require('net').createServer((socket) =>
      socket.setEncoding 'utf8'

      # init interval memory requests when server is up
      int = setInterval =>
        socket.write 'getUsage' unless socket.writable isnt true
        log.info 'request memory usage' if @debug
      , @interval

      socket.on 'data', (data) =>
        log.info "got new data: #{data}" if @debug
        @emitter.emit 'memUsg', data

      @emitter.on 'die', ->
        log.warn 'server will shutdown' if @debug
        clearInterval int
        # tell connected clients to exit
        socket.close 'die'
        # finally close the server
        server.close

    ).listen serverPort

module.exports = MemoryMaster
