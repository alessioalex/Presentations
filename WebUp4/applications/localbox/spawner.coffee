util  = require('util')
spawn = require('child_process').spawn
log   = console.log
colors = require 'colors'

runIt = (callback) ->
  fileServer = spawn('coffee', ['httpFileServer.coffee'])

  fileServer.stdout.on 'data', (data) ->
    data = data.toString().trim()
    log "stdout", data
    data = JSON.parse data
    if data.port
      log "Static file server port: #{data.port}"
      # node style: error is the first param
      callback null, data.port
    else
      callback(new Error('did not start'))

  fileServer.stderr.on 'data', (data) ->
    data = data.toString().trim()
    log "Static file server - stderr: #{data}"

  fileServer.on 'exit', (code) ->
    log "Static file server -> child process exited with code #{code}".red

module.exports = runIt
