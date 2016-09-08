###
under.js: Stream responsible for emitting events under a fixed value.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Under (floor)
# #### @floor {number} Floor value to compare to `.metric` values.
# Constructor function of the Under stream responsible for emitting
# events over a fixed value.
#
class Under extends stream.Transform
  constructor: (@floor) ->
    super objectMode: true

    throw new Error "floor is required." unless @floor?

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data only if `.metric` is under `this.floor`.
  #
  _transform: (data, encoding, done) ->
    @push data if data.metric < @floor
    done()


module.exports = Under
