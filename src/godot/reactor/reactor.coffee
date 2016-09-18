#
# * reactor.js: Reactor object responsible for creating pipe chains of streams for reacting to events.
# *
# * (C) 2012, Nodejitsu Inc.
# *
#
events = require "events"
uuid   = require "node-uuid"
stream = require "readable-stream"


#reactor
# ### function Reactor ()
# #### @options {string|Object} Options for this reactor
# Constructor function for the Reactor object responsible for creating
# pipe chains of streams for reacting to events.
#
class Reactor extends events.EventEmitter
  #
  # Inherit from event emitter for error propagation
  #

  constructor: (options = {}) ->
    options   = name: options if typeof options is "string"
    @reactors = []
    @id       = uuid.v4()
    @name     = options.name

  chainReactors: (last, nextOptions) =>
    stream      = new nextOptions.Factory nextOptions.args...
    stream.name = @name
    stream.id   = @id
    stream.on "error", @emit.bind this, "error"
    stream.on "reactor:error", @emit.bind this, "reactor:error"
    last.pipe stream

  #reactor
  # ### function createStream ()
  # Instantiates a new and unique pipe-chain for the reactors
  # associated with this instance.
  #
  createStream: (source = new stream.PassThrough) ->
    source.on "error", @emit.bind this, "error"
    @reactors.reduce @chainReactors, source


module.exports = Reactor
