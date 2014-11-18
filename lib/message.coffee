redis   = require("redis").createClient()
Promise = require("promise")

redis.on "error", (err) ->
  console.error "[redis] connection error: #{client.host}:#{client.port}"
  console.error "[redis] #{err}"

class Message

  @key: (jid) -> "offline:#{jid}" # ex: "offline:j@srv.im"

  constructor: (jid, stanza) ->
    @stanza = stanza
    @jid = jid
    @key = Message.key(jid)

  # Removes and returns the last message of the list stored
  # on Redis for this JID.
  @for: (jid) ->
    return new Promise (fulfill, reject) ->
      redis.rpop Message.key(jid), (error, stanza) ->
        # server error
        return reject(error) if error?
        # message found
        return fulfill(new Message(jid, stanza)) if stanza?
        # no more messages
        reject(null)

  # Only allow up to 100 offline messages per JID. Start trimming
  # from the oldest message (first in the list)
  @trim: (jid) ->
    return new Promise (fulfill, reject) ->
      redis.ltrim Message.key(jid), 0, 99, (err) ->
        if err then reject(err) else fulfill(true)

  # Save message to the user's offline list in Redis
  save: ->
    return new Promise (fulfill, reject) =>
      redis.lpush @key, @stanza, (err, res) ->
        if err then reject(err) else fulfill(res)

module.exports = Message
