colors = require 'colors'

colors.setTheme
  silly   : 'rainbow'
  input   : 'grey'
  verbose : 'cyan'
  prompt  : 'grey'
  info    : 'green'
  data    : 'grey'
  help    : 'cyan'
  warn    : 'yellow'
  debug   : 'blue'
  error   : 'red'

logger =

  info: (msg) ->
    console.log msg.info

  warn: (msg) ->
    console.log msg.warn

  error: (msg) ->
    console.log msg.error

module.exports = logger
