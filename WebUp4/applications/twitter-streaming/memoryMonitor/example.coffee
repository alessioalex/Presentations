log = require './logger'
MemoryMaster = require './MemoryMaster'
MemoryMonitor = require './MemoryMonitor'

EventEmitter = require('events').EventEmitter
EE = new EventEmitter()
# intercept memory usage data
# EE.on 'memUsg', (data) ->
  # log.info data

masterOpts =
  interval: 2000
  # debug: true

# monitorOpts =
#   debug: true

appMaster = new MemoryMaster(masterOpts, EE)
# appMemUsg = new MemoryMonitor('testApp', monitorOpts)

module.exports = EE
