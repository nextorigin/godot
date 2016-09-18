###
under-meta.js :: Stream responsible for emitting events under a fixed value for a specific meta key
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function UnderMeta (key, floor)
# #### @key {String} any key that would possibly be found in the meta property
# #### @floor {Number} Value to compare to `.meta[this.key]` value to
# Constructor function of the UnderMeta stream that emits events under a fixed
# value for a specific meta key
#
class UnderMeta extends stream.Transform
  constructor: (@key, @floor) ->
    super objectMode: true

    throw new Error "both meta key and floor value required" unless @key and @floor

  #
  # ### function write (data)
  # #### @data {Object} JSON to assess
  # Emits data only if `.meta[this.key]` is under `this.floor`
  #
  _transform: (data, encoding, done) ->
    val = data.meta?[@key]
    return unless val and val < @floor
    @push data
    done()


module.exports = UnderMeta

