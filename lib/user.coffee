redis   = require("redis").createClient()
Promise = require("promise")
_       = require("lodash")

redis.on "error", (err) ->
  console.error "[redis] connection error: #{client.host}:#{client.port}"
  console.error "[redis] #{err}"

class User

  @key: (jid) -> "user:#{jid}"

  constructor: (jid, attrs = {}) ->
    @jid = jid
    @attrs = attrs

  @find: (jid) ->
    return new Promise (fulfill, reject) ->
      redis.hgetall User.key(jid), (err, obj) ->
        return reject(err)  if err
        return reject(null) if _.isEmpty(obj)

        return fulfill(new User(jid, obj))

  delete: (callback) ->
    return new Promise (fulfill, reject) ->
      redis.del @key, (err, obj) ->
        if err then reject(err) else fulfill(@)

  save: ->
    return new Promise (fulfill, reject) ->
      redis.hmset @key, @attrs, (err, obj) ->
        if err then reject(err) else fulfill(@)

  # Clients should send JID & password, along with a callback
  # containing a Promise:
  #
  #   auth = client.trigger("authenticate", "j@id.com", "p@ss").then(
  #     function(user){
  #       // Success
  #     }, function(err) {
  #       // Fail
  #     })
  #
  @authenticate: (jid, password) ->
    return new Promise (fulfill, reject) ->
      User.find(jid).then (user) ->
        if !user?
          return reject(new Error("User not found"))

        if user.password isnt password
          return reject(new Error("Authentication failure"))

        fulfill(user)
      , reject

  # Register a new user.
  #
  #   user = client.trigger("register", {
  #     jid: "test@test.com",
  #     password: "123"
  #   }).then(function(user){
  #     // Success
  #   }, function(err) {
  #     // Fail
  #   })
  #
  @register: (data) ->
    return new Promise (fulfill, reject) ->
      User.find(data.jid).then (user) ->
        if user and !options.force
          reject(new Error("There is already a user with that JID"))
        else
          new User(data.jid, data).save().then(fulfill, reject)
      , reject

module.exports = User;
