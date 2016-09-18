###
rollup.js: Stream for rolling up events over a given time interval.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
errify = require "errify"


#
# ### function Rollup (options, || interval, limit)
# #### @options {Object} Options for this instance
# #### @[options.]limit    {Number} Number of events for each interval.
# #### @[options.]interval {Number} Interval to rollup events over.
# Constructor function of the Rollup stream responsible for rolling
# up events over a given time interval. **Defaults to one hour rollup.**
#
class Rollup extends stream.Transform
  constructor: (interval, limit) ->
    super objectMode: true

    options = undefined
    if typeof interval is "object"
      options = interval
    else
      options =
        interval: interval
        limit: limit

    @limit      = options.limit or 100
    @interval   = options.interval or 1000 * 60 * 60
    @forceReset = typeof interval is "function"
    @duration   = 0
    @period     = 0
    @events     = []
    @next       = []

  #
  # ### function write (data)
  # #### @data {Object} JSON to rollup.
  # Adds the specified `data` to the events
  # rolled up by this instance.
  #
  _transform: (data, encoding, done) ->
    if @events.length is @limit
      #
      # Remark: Should we drop events here?
      #
      @next.push data
    else
      @events.push data
    @resetInterval() unless @intervalId
    done()

  #
  # ### function resetInterval ()
  # Resets the interval for this instance.
  #
  resetInterval: ->
    #
    # Set the nextInterval to the calculated value
    # of the interval function or the static interval value.
    #
    nextInterval = if typeof @interval is "function" then @interval @period, @duration else @interval
    if @intervalId
      clearInterval @intervalId
      delete @intervalId

    @intervalId = setInterval (@rollup.bind this, nextInterval), nextInterval

  rollup: (nextInterval) =>
    if @events.length
      @duration += nextInterval
      @period   += 1
      @push [@events[0..]]
      @events.length = 0

      i = 0
      while i < @next.length
        @events[i] = @next[i]
        i++

      @next.length = 0
      #
      # Remark: Basic unit testing was not effective to see if
      # this could cause StackOverflow exceptions. Process ran
      # out of memory before a StackOverflow exception was thrown.
      # A long running stress test would determine this.
      #
      @resetInterval() if @forceReset


module.exports = Rollup
