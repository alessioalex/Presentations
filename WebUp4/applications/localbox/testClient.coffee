request = require 'request'
fs = require 'fs'
EventEmitter = require('events').EventEmitter
EE = new EventEmitter()
MessageBus = require './MessageBus'
bus = new MessageBus({ debug: false })
lastMsg = null
log = console.log
TCPPort = process.argv[2]
fileServerPort = null
host = '127.0.0.1'
syncDir = __dirname + '/fromOthers'

removeFile = (filename, callback) ->
  return false if fileServerPort is null
  filePath = syncDir + "/#{filename}"
  log "Removing file #{filePath}"
  fs.unlink filePath, callback

downloadFile = (filename) ->
  return false if fileServerPort is null
  # delete previous file with that name, just in case
  filePath = syncDir + "/#{filename}"
  toDownload = "http://#{host}:#{fileServerPort}/#{filename}"
  removeFile filename, (err) ->
    log "downloading file: #{toDownload} --> #{filePath} "
    request(toDownload).pipe(fs.createWriteStream(filePath))

bus.startClient TCPPort, host, ->
  log 'connected to localbox server'

  setTimeout ->
    bus.emit 'clientMsg', 'ls'
  , 500

  bus.on 'clientData', (data) ->
    lastMsg = data
    if data.f_rem
      removeFile data.f_rem
    else if data.f_new
      downloadFile data.f_new
    else if data.f_change
      downloadFile data.f_change
    else if data.files
      if data.port then fileServerPort = data.port
      if Array.isArray(data.files)
        data.files.map (filename) ->
          process.nextTick ->
            downloadFile(filename)
