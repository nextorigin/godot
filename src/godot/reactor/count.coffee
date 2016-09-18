###
count.js: Stream responsible for emitting number of messages over an interval.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
clone  = require "clone"


#
# ### function Count (interval)
# #### @interval {number} Interval in ms to count messages over.
# Constructor function of the Count stream responsible for emitting
# number of messages over an interval.
#
class Count extends stream.Transform
  constructor: (@interval) ->
    super objectMode: true

    throw new Error "interval is required." unless typeof @interval is "number"
    @_name = "count"
    @interval = interval
    @count = 0

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data only if `.metric` is over `this.ceiling`.
  #
  _transform: (data, encoding, done) ->
    if typeof data.metric is "number"
      @count += 1
      @last = data
    @resetInterval() unless @intervalId
    done()

  #
  # ### function resetInterval ()
  # Resets the count for this instance on the
  # specified `this.interval`.
  #
  resetInterval: ->
    clearInterval @intervalId if @intervalId
    @intervalId = setInterval @count, @interval

  count: =>
    return unless @count
    data        = clone @last
    data.metric = @count
    data.time   = +Date.now()
    data.tags   = data.tags or []
    data.tags.push "per #{@interval / 1000}s"
    @count      = 0
    @last       = null
    @push data


module.exports = Count
