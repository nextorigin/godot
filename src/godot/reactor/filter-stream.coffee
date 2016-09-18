###
filter-stream.js: Simple readable and writable stream that filters key by value.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function ReadWriteStream ()
# A aimple readable and writable stream that filters key by value.
#
class FilterStream extends stream.Transform
  constructor: (@key, @value) ->
    super objectMode: true

  #
  # ### function write (data)
  # Emits the "data" event with the pass-thru `data`.
  #
  _transform: (data, encoding, done) ->
    @push data if data[@key] is @value
    done()


module.exports = FilterStream
