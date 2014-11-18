redis      = require("redis").createClient()
Promise    = require("promise")
RosterItem = require("./roster_item.coffee")

redis.on "error", (err) ->
  console.error "[redis] connection error: #{client.host}:#{client.port}"
  console.error "[redis] #{err}"

class Roster

  @key: (jid) -> "roster:#{jid}"

  constructor: (jid) ->
    @owner = jid
    @items = []
    @key = Roster.key(jid)

  @find: (jid) -> new Roster(jid).refresh()

  refresh: ->
    roster = @

    return new Promise (fulfill, reject) ->
      redis.smembers @key, (err, contacts) ->
        return reject(err) if err?

        roster.items = []

        # no contact list, or the list is empty
        if !contacts? or contacts.length is 0
          return fulfill(roster)

        contacts.forEach (contact) ->
          RosterItem.find(roster, contact).then (item) ->
            counts++;
                    self.items.push(item);
                    if(counts == obj.length) {
                        cb(self);
                    }
                });
            });
        }
    });
};

Roster.prototype.eachSubscription = function(types, callback) {
    var self = this;
    self.refresh(function() {
        self.items.forEach(function(item) {
            if(types.indexOf(item.state) >= 0) {
                callback(item);
            }
        });
    });
};

Roster.prototype.itemForJid = function(jid, callback) {
    var self = this;
    RosterItem.find(self, jid, function(item) {
        callback(item);
    });
};

Roster.prototype.subscriptions = function(types, callback) {
    // TODO
};

Roster.prototype.add = function(jid, callback) {
    var self = this;
    self.itemForJid(jid, function(item) {
        // And now also add the jid to the set
        client.sadd(Roster.key(self.owner), item.jid, function(err, obj) {
            callback(item);
        });
    });
};

RosterItem.prototype.save = function(callback) {
    var self = this;
    client.hmset(RosterItem.key(self.roster.owner, self.jid), {state: self.state, name: self.name}, function(err, obj) {
        self.roster.add(self.jid, function() {
            callback(err, self);
        });
    });
}

RosterItem.prototype.delete = function(callback) {
    var self = this;
    client.del(RosterItem.key(self.roster.owner, self.jid), function(err, obj) {
        client.srem(Roster.key(self.roster.owner), self.jid, function(err, obj) {
            callback(err, self);
        });
    });
}

RosterItem.find = function(roster, jid, cb) {
    var self = this;
    client.hgetall(RosterItem.key(roster.owner, jid), function(err, obj) {
        if(isEmpty(obj)) {
            cb(new RosterItem(roster, jid, "none", ""));
        }
        else {
            cb(new RosterItem(roster, jid, obj.state, obj.name));
        }
    });
}

exports.Roster = Roster;
exports.RosterItem = RosterItem;


function isEmpty(ob){
   for(var i in ob){ if(ob.hasOwnProperty(i)){return false;}}
  return true;
}
