###
by.js: Stream for creating a new set of streams based on a key change
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


FilterStream = require "../../../lib/godot/common/filter-stream"
#
# ### function By (keys, reactor)
# #### @key {string|Array} Particular key to listen for a change
# #### @reactor {godot.reactor().type()} Reactor or reactor chain to be created
# #### @options {Object} options object
# ####   @recombine {Boolean} Recombines the data from the split streams
# Constructor function for the by stream to trigger the creation of a new set
# of streams based on a key change.
#
class By extends stream.Transform
  constructor: (@keys, @reactor, @options = {}) ->
    super objectMode: true

    if (typeof @keys isnt "string") and (not Array.isArray @keys) or not (@reactor instanceof stream.Stream)
      throw new Error "This reactor takes key(s) and a reactor as arguments"

    @keys      = [keys] unless Array.isArray @keys
    @recombine = @options.recombine or false
    @sources   = @keys.reduce(((all, key) ->
      all[key] = {}
      all
    ), {})
    @streams   = @keys.reduce(((all, key) ->
      all[key] = {}
      all
    ), {})

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Creates a new pipe-chain for `this.reactor`
  # for any unique values for all of `this.keys`
  # and pipes `data` to them.
  #
  _transform: (data, encoding, done) ->
    #
    # TODO: Internal error handling here with this internal pipe chain
    #
    for key in @keys
      value = data[key]

      unless @streams[key][value]
        @sources[key][value] = new FilterStream key, value
        @streams[key][value] = @sources[key][value].pipe @reactor

        if @recombine
          sink = new stream.Writable objectMode: true
          sink._write = @_writeSink
          @streams[key][value].pipe sink

      @sources[key][value].write data

    unless @recombine
      @push data

    done()

  _writeSink: (data, encoding, done) =>
    @push data
    done()


module.exports = By
