###
over-meta.js :: Stream responsible for emitting events over a fixed value for a specific meta key
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function OverMeta (key, ceiling)
# #### @key {String} Any key that would possibly be found in the meta property
# #### @ceiling {Number} Value to compare the `.meta[this.key]` value to
# Constructor function of the OverMeta stream that emits events over
# a fixed value for a specific meta key
#
class OverMeta extends stream.Transform
  constructor: (@key, @ceiling) ->
    super objectMode: true

    throw new Error "both meta key and ceiling value required" unless @key and @ceiling

  #
  # ### function write (data)
  # #### @data {Object} JSON to assess
  # Emits data only if `.meta[this.key]` is over `this.ceiling`
  #
  _transform: (data, encoding, done) ->
    val = data.meta?[@key]
    return unless val and val > @ceiling
    @push data
    done()


module.exports = OverMeta
