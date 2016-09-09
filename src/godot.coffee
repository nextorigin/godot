###
godot.js: Top-level include for the `godot` module.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

#
# ### @net {Object}
# Expose `net` module for creating `udp` and
# `tcp` servers.
#
exports.net = require('./godot/net')

#
# ### @reactor {Object}
# Expose `reactor` module for processing and
# reacting to events.
#
require('./godot/reactor') exports

#
# ### @producer {Object}
# Expose `producer` module for creating events
# to process and react to.
#
exports.producer = require('../lib/godot/producer')

#
# ### @common {Object}
# Expose `common` module for performing basic
# streaming.
#
exports.common = require('../lib/godot/common')

#
# ### @math {Object}
# Expose `math` module for performing basic
# math on sets of events.
#
exports.math = require('../lib/godot/common/math')

#
# ### function createServer (options)
# #### @options {Object} Options for the server
# ####   @options.type     {udp|tcp} Networking protocol of the server
# ####   @options.reactors {Array}   List of reactor streams
# Creates a new `net.Server` of the specified `options.type`
# for a set of reactors.
#
exports.createServer = (options) ->
  options = options or {}
  options.type = options.type or 'udp'
  new (exports.net.Server)(options)

#
# ### function createClient (options)
# #### @options {Object} Options for the client
# ####   @options.type      {udp|tcp} Networking protocol of the client
# ####   @options.producers {Array}   List of producer streams
# Creates a new `net.Client` of the specified `options.type`
# for a set of producers.
#
exports.createClient = (options) ->
  options = options or {}
  options.type = options.type or 'udp'
  new (exports.net.Client)(options)

