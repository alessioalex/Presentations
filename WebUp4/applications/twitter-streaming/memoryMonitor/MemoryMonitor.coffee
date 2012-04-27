net = require 'net'
colors = require 'colors'
log = require './logger'
serverPort = 5000

class MemoryMonitor
  constructor: (@name, options) ->
    @connect()
    @debug = options?.debug

  connect: ->
    conn = net.createConnection serverPort

    conn.setEncoding 'utf8'

    conn.on 'connect', ->
      log.info 'Connected to server' if @debug

    conn.on 'data', (data) =>
      if data is 'getUsage'
        memUsg = JSON.stringify(@getUsage())
        log.info "Sending memory usage: #{memUsg}" if @debug
        conn.write memUsg

    conn.on 'close', (data) ->
      if data isnt 'die'
        setTimeout ->
          log.info "Trying to reconnect to server" if @debug
          # only reconnect in case 'die' hasn't been sent
          conn.connect serverPort
        , 1500

    conn.on 'error', (data) ->
      log.error "Memory server connection error" if @debug
      # an error has occured

  bytesToSize: (bytes, precision = "MB") ->
    sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
    posttxt = 0

    if bytes == 0
        return 'n/a'
    while bytes >= 1024
      posttxt++
      bytes = bytes / 1024

    bytes.toFixed(precision) + " " + sizes[posttxt]

  getUsage: ->
    memUsg = process.memoryUsage()

    return {
      appName: @name,
      usage: @bytesToSize memUsg.rss, 2
    }

module.exports = MemoryMonitor
