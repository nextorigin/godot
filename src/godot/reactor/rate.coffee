###
rate.js: Stream responsible for emitting summing metrics over an interval and
         divide by interval size.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
clone  = require "clone"


#
# ### function Rate (ceiling)
# #### @interval {number} Interval in ms to rate messages over.
# Constructor function of the Rate stream responsible for emitting
# summing metrics over an interval and divide by interval size.
#
class Rate extends stream.Transform
  constructor: (@interval) ->
    super objectMode: true

    throw new Error "interval is required." unless typeof @interval is "number"

    @sum = 0
    @size = 0

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data only if `.metric` is over `this.ceiling`.
  #
  _transform: (data, encoding, done) ->
    if typeof data.metric is "number"
      @sum  += data.metric
      @size += 1
      @last  = data

    @resetInterval() unless @intervalId
    done()

  #
  # ### function resetInterval ()
  # Resets the sum for this instance on the
  # specified `this.interval`.
  #
  resetInterval: ->
    clearInterval @intervalId if @intervalId
    @intervalId = setInterval @rate, @interval * 1000

  rate: =>
    return unless @size

    data        = clone @last
    data.metric = @sum / @size
    data.time   = +Date.now()
    data.ttl    = @interval

    @sum        = 0
    @size       = 0
    @last       = null

    @push data


module.exports = Rate
