###
over.js: Stream responsible for emitting events over a fixed value.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Over (ceiling)
# #### @ceiling {number} Ceiling value to compare to `.metric` values.
# Constructor function of the Over stream responsible for emitting
# events over a fixed value.
#
class Over extends stream.Transform
  constructor: (@ceiling) ->
    super objectMode: true

    throw new Error "ceiling is required." unless @ceiling?

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data only if `.metric` is over `this.ceiling`.
  #
  _transform: (data, encoding, done) ->
    @push data if data.metric > @ceiling
    done()


module.exports = Over
