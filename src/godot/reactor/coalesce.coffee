###
coalesce.js: Stream responsible for remembering and emitting vectors of events for `host/service` combinations.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Coalesce (formatFn)
# Constructor function of the Coalesce stream responsible for remembering
# and emitting vectors of events for `host/service` combinations.
#
class Coalesce extends stream.Transform
  constructor: (formatFn) ->
    super objectMode: true

    @keys = {}
    @events = []

  #
  # ### function write (data)
  # #### @data {Object} JSON to output
  # Attempts to set the event for the `data.host` and
  # `data.service` combination and pushes it to `this.events`.
  # If it already exists, replaces it in `this.events` before
  # emitting data.
  #
  _transform: (data, encoding, done) ->
    key = "#{data.host}/#{data.service}"
    if @keys[key]
      @events.splice (@events.indexOf @keys[key]), 1, data
    else
      @events.push data
    @keys[key] = data

    @push @events[0..]
    done()


module.exports = Coalesce
