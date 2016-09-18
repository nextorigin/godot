###
mean.js: Stream responsible for calculating the mean of metrics on events.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Mean ()
# Constructor function of the Mean stream responsible for aggregating
# metrics on events.
#
class Mean extends stream.Transform
  constructor: ->
    super objectMode: true

    @total = 0
    @length = 0

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Writes the data but updates the metric to
  # be the mean of all `.metric` values over time.
  #
  _transform: (data, encoding, done) ->
    @length++
    @total += data.metric
    data.metric = @total / @length
    @push data
    done()


module.exports = Mean
