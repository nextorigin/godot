###
meta.js: Stream for setting the value (and any meta) from a second reactor on any data received.
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


class MetaMetric extends stream.Writable
  constructor: (@key) ->
    super objectMode: true

  _write: (data, encoding, done) ->
    data.meta = data.meta or {}
    data.meta[@key] = data.metric
    data.metric = data._metric
    delete data._metric
    @push data
    done()

#
# ### function Meta (tag, reactor)
# #### @key {string} Meta key to use for the value of `reactor`.
# #### @reactor {godot.reactor().type()} Reactor to be created
# Constructor function for the Meta stream responsible for setting
# the value (and any meta) from a second reactor on any data received.
#
class Meta extends stream.Transform
  constructor: (@key, @reactor) ->
    super objectMode: true

    @stream = new MetaMetric @key
    @reactor.pipe @stream
    @stream.push = @push.bind this

    @stream.on  "error", @error
    @reactor.on "error", @error

  #
  # ### function write (data)
  # Writes the `data` to the meta stream associated
  # with this instance and sets `_metric` so it can
  # be replaced later on.
  #
  _transform: (data, encoding, done) ->
    data._metric = data.metric
    @reactor.write data
    done()

  error: (err) => @emit "error", err


module.exports = Meta
