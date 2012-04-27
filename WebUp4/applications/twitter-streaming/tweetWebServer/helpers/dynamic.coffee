# Dynamic view helpers are simply functions which accept req, res
# and are evaluated against the Server instance before a view is rendered
# The return value of this function becomes the local variable it is associated with
module.exports = (app) ->
  app.dynamicHelpers
    session: (req, res) ->
      req.session

    flash: (req, res) ->
      req.flash()

    csrf: (req, res) ->
      req.session._csrf

    custom: (req, res) ->
      # define your custom helper here
