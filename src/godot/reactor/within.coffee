###
within.js: Stream responsible for emitting events if they fall within a given inclusive range.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Within (mix, max)
# #### @min {number} Floor value to compare to `.metric` values.
# #### @max {number} Ceiling value to compare to `.metric` values.
# Constructor function of the Over stream responsible for emitting
# events if they fall within a given inclusive range {min, max}.
#
class Within extends stream.Transform
  constructor: (@min, @max) ->
    super objectMode: true

    throw new Error "both min and max are required." unless typeof @min is "number" and typeof @max is "number"

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data only if `.metric` is under `this.max`
  # and over `this.min`.
  #
  _transform: (data, encoding, done) ->
    return done() unless typeof data.metric is "number"
    @push data if @max >= data.metric and @min <= data.metric
    done()


module.exports = Within
