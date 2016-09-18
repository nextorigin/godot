###
throttle.js: Stream for throttling events over a given time interval.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Throttle (length|options, interval)
# #### @options  {Object} Options containing max and interval
# #### @max      {Number} Maximum number of events to emit before throttleing.
# #### @interval {Number} Interval to throttle events over.
# Constructor function of the Throttle stream responsible for throttling
# events over a given time interval. **Defaults to 10 event maximum and
# five minute interval.**
#
class Throttle extends stream.Transform
  constructor: (max, interval) ->
    super objectMode: true

    if typeof max is "object"
      options = max
    else
      options =
        max: max
        interval: interval

    @max      = options.max or 10
    @interval = options.interval or 1000 * 60 * 5
    @length   = 0

  #
  # ### function write (data)
  # #### @data {Object} JSON to rollup.
  # Emits the specified `data` only if we have not
  # emitted `this.max` events over `this.interval`.
  #
  _transform: (data, encoding, done) ->
    #
    # If we've passed the `max` number of events
    # to emit, then drop this `data`.
    #
    return done() if @max <= @length
    @push data
    @length++
    @resetInterval() unless @intervalId
    done()

  #
  # ### function resetInterval ()
  # Resets the length of this instance on the
  # specified `this.interval` for this instance.
  #
  resetInterval: ->
    clearInterval @intervalId if @intervalId
    @intervalId = setInterval (=> @length = 0), @interval


module.exports = Throttle
