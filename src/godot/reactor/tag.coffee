###
tag.js: Stream for setting the value (and any tags) from a second reactor on any data received.
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


class TagMetric extends stream.Writable
  constructor: (@tag) ->
    super objectMode: true

  _write: (data, encoding, done) ->
    data.tags   or= []
    data.tags.push "#{@tag}:#{data.metric}"
    data.metric   = data._metric
    delete data._metric
    @push data
    done()

#
# ### function Tag (tag, reactor)
# #### @tag {string} Tag to use for the value of `reactor`.
# #### @reactor {godot.reactor().type()} Reactor to be created
# Constructor function for the tag stream responsible for setting
# the value (and any tags) from a second reactor on any data received.
#
class Tag extends stream.Transform
  constructor: (@tag, @reactor) ->
    super objectMode: true

    @stream = new TagMetric @tag
    @reactor.pipe @stream
    @stream.push = @push.bind this

    @stream.on  "error", @error
    @reactor.on "error", @error
    @reactor.on "reactor:error", @error

  #
  # ### function write (data)
  # Writes the `data` to the tag stream associated
  # with this instance and sets `_metric` so it can
  # be replaced later on.
  #
  _transform: (data, encoding, done) ->
    data._metric = data.metric
    @reactor.write data
    done()

  error: (err) => @emit "reactor:error", err


module.exports = Tag
