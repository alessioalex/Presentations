express = require 'express'
server  = express.createServer()
finalPort = null
log     = console.log
ports   = ['3000', '4000', '4001', '4002', '4003', '4004', '4005', '5000', '6000', '7000', '8000', '8080', '9000']

defaultResponse = (req, res) ->
  res.writeHead 200, 'Content-Type': 'text/html'
  res.end 'Static file server for localbox.'

server.configure ->
  server.use express.static(__dirname + '/shared')
  server.use defaultResponse

bindServer = (server) ->
  return false if finalPort isnt null
  port = ports.shift()
  if !port then console.error "could not bind to any ports"
  server.listen port, ->
    finalPort = port
    setTimeout ->
      log JSON.stringify({ port: port }) if finalPort is port
    , 500

bindServer server

process.on 'uncaughtException', (err) ->
  if err.code is 'EADDRINUSE'
    finalPort = null
    bindServer server
  else
    throw err
