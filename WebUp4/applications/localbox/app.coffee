watch   = require 'watch'
log     = console.log
colors  = require 'colors'
fs      = require 'fs'
sharedDir = __dirname + '/shared'
MessageBus = require './MessageBus'
bus = new MessageBus()
startFileServer = require './spawner'
fileServerPort = null

# File functions {
allowedExtensions = [ 'gif', 'jpg', 'jpeg', 'png', 'txt', 'zip']

getWhatsAfter = (path, char = '.') ->
  i = path.lastIndexOf char
  if i < 0 then return '' else return path.substr i+1

checkAllowed = (element, index, array) ->
  allowedExtensions.indexOf(getWhatsAfter(element)) isnt -1

readDirectory = (path, callback) ->
  fs.stat path, (err, stat) ->
    if err then throw err
    fs.readdir path, (err, files) ->
      if err then throw err
      callback files.filter(checkAllowed)

getFilename = (filepath) ->
  filename = getWhatsAfter(filepath, '/')

shouldBroadcast = (filepath) ->
  filename = getWhatsAfter(filepath, '/')
  return checkAllowed(filename)
# }


# On start TCP server {
bus.on 'serverUp', (address) ->
  watch.createMonitor sharedDir, ignoreDotFiles: true , (monitor) ->
    # Handle new files
    monitor.on "created", (filepath, stat) ->
      if shouldBroadcast(filepath)
        bus.send 'f_new': getFilename(filepath)
    # Handle file changes
    monitor.on "changed", (filepath, curr, prev) ->
      if shouldBroadcast(filepath)
        bus.send 'f_change': getFilename(filepath)
    # Handle removed files
    monitor.on "removed", (filepath, stat) ->
      if shouldBroadcast(filepath)
        bus.send 'f_rem': getFilename(filepath)

  bus.on 'serverLs', (sid) ->
    readDirectory sharedDir, (files) ->
      bus.emit 'serverMsg', { files: files, port: fileServerPort }, sid
      log 'emitting serverMsg', { files: files, port: fileServerPort }, sid
# }

startFileServer (err, port) ->
  if err
    throw err
  else
    # log "#{port} -> port".cyan
    fileServerPort = port
    bus.startServer()

