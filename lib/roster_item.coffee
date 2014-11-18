redis   = require("redis").createClient()
Promise = require("promise")

redis.on "error", (err) ->
  console.error "[redis] connection error: #{client.host}:#{client.port}"
  console.error "[redis] #{err}"

class RosterItem

  @key: (owner, jid) -> "rosterItem:#{owner}:#{jid}"

  constructor: (roster, jid, state, name) ->
    @roster = roster
    @jid    = jid
    @state  = state
    @name   = name
