###
net.js: Test helpers for working with `godot.net`.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

errify = require "errify"

godot  = require "../../src/godot"

#
# ### function createServer (options, callback)
# Creates a `godot` server with the specified `options`.
#
exports.createServer = (options, callback) ->
  ideally = errify callback

  options.type or= "tcp"
  server = godot.createServer
    type: options.type
    reactors: options.reactors
    multiplex: options.multiplex

  switch options.type
    when "tcp", "udp"
      await server.listen options.port, (options.host or "localhost"), ideally defer()
    when "unix"
      await server.listen options.path, ideally defer()

  callback null, server

#
# ### function getStreams (obj, name)
# #### @obj {godot.net.Client|godot.net.Server} Object holding streams
# #### @names {string|Array} **Optional** Name(s) of streams to find
# Returns the set of instantiated streams on the `godot.net obj` filtering
# for names (if any).
#
exports.getStreams = (obj, names) ->
  names = [names] if typeof names is "string"

  if obj.reactors
    #
    # TODO: Support more than one host
    #
    key = Object.keys(obj.hosts)[0]
    return obj.hosts[key].map (pair) -> pair.dest
                         .filter (stream) -> !names or ~names.indexOf stream.name

  else if obj.producers
    #
    # TODO: Support producers
    #
  else

#
# ### function getStream (obj, name)
# #### @obj {godot.net.Client|godot.net.Server} Object holding streams
# #### @name {string} **Optional** Name(s) of streams to find
# Returns a single instantiated stream on the `godot.net obj` with the
# specified `name`.
#
exports.getStream = (obj, name) ->
  exports.getStreams(obj, name)[0]
