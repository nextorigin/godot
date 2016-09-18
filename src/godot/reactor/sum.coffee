###
sum.js: Stream responsible for summing metrics on events.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Sum ()
# Constructor function of the Sum stream responsible for aggregating
# metrics on events.
#
class Sum extends stream.Transform
  constructor: ->
    super objectMode: true

    @total = 0

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Writes the data but updates the metric to
  # be the sum of all `.metric` values over time.
  #
  _transform: (data, encoding, done) ->
    @total      += data.metric
    data.metric  = @total
    @push data
    done()


module.exports = Sum
