###
combine.js: Stream responsible for combining an event vector (like from a window).
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
clone  = require "clone"


#
# ### function Combine (combineFn)
# #### @combine {function} Combine function to call on each event vector.
# Constructor function of the Combine stream responsible for
# combining an event vector (like from a window).
#
class Combine extends stream.Transform
  constructor: (@combineFn) ->
    super objectMode: true

    throw new Error "combine function is required." unless @combineFn? and typeof @combineFn is "function"

  #
  # ### function write (data)
  # #### @data {Array} JSON event vector to combine
  # Emits data after it is mutating with `this.mapFn`.
  #
  _transform: (data, encoding, done) ->
    last = clone data[-1..]
    #
    # Set time and other critical events
    #
    last.time   = +Date.now()
    last.metric = @combineFn data
    @push last
    done()


module.exports = Combine
