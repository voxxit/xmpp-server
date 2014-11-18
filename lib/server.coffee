XMPP = require("node-xmpp")
User = require("./user.coffee")

exports.run = (config, ready) ->

  # Creates the server.
  server = new XMPP.C2SServer(config)

  # Configure the modules.
  #
  # Require the module using the namespaced configuration from
  # the server object. If namespaced configuration ins't found,
  # we'll just send the entire config object.
  config.modules.forEach (key) ->
    require("./modules/#{key}").configure(server, config[key] or config)

  # Handle a connecting client
  server.on "connect", (client) ->
    client.on "authenticate", User.authenticate
    client.on "register", User.register

  server.on "disconnect", (client) ->

  # This is a callback to trigger when the server is ready.
  # That's very useful when running a server in some other code.
  #
  # TODO: We may want to make sure this is the right place.
  ready()
