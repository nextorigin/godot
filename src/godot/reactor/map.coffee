###
map.js: Stream responsible for mapping events before emitting them.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
errify = require "errify"


#
# ### function Map (mapFn)
# #### @mapFn {function} Map function to call on each event.
# #### @options {Object} options to pass into reactor to customize behavior
# Constructor function of the Map stream responsible for mapping
# events before emitting them.
#
class Map extends stream.Transform
  constructor: (@mapFn, options = {}) ->
    super objectMode: true

    throw new Error "map function is required." unless @mapFn? and typeof @mapFn is "function"

    @async = mapFn.length is 2
    #
    # So by default the behavior is to block the stream when running through
    # the async function. This option is here to allow you to do an async
    # operation that does not block the stream
    # TODO: Think of a better API for this behavior
    #
    @passThrough = options.passThrough or false

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data after it is mutating with `this.mapFn`.
  #
  _transform: (data, encoding, done) ->
    unless @async
      @push @mapFn data
      return done()

    ideally = errify (err) => @emit "reactor:error", err

    unless @passThrough
      await @mapFn data, ideally defer processed
      @push processed
      return done()

    await @mapFn data, ideally defer()
    @push data
    return done()


module.exports = Map
