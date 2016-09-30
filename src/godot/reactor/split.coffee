###
split.js: Stream responsible for splitting a stream based on a function or unique key
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
uuid   = require "node-uuid"
Chain  = require "./chain"
Filter = require "./filter-stream"


class FilterOnFn extends stream.Transform
  constructor: (@uniqueifier, @value) ->
    super objectMode: true

  _transform: (data, encoding, done) ->
    @push data if (@uniqueifier data) is @value
    done()


#
# ### function Split (differentiator, streamFactory)
# #### @differentiator {Function | String}
# ####   Function which returns a String UUID representing a unique stream path
# ####   String key of the event which should create a new stream for every unique value
# #### @streamFactory {Function}
# ####   Function which returns a stream.  The unique value or UUID will be passed as the first argument.
# Constructor function of the Split stream responsible for splitting streams
#
class Split extends stream.Transform
  constructor: (@differentiator, @streamFactory) ->
    super objectMode: true

    throw new Error "differentiator and streamFactory are required." unless @differentiator and @streamFactory

    @ids     = []
    @streams = {}

    if typeof @differentiator is "string"
      @uniqueifier = @valueForKey @differentiator
      @splitter = Filter
    else
      @uniqueifier = @differentiator
      @splitter = FilterOnFn

  valueForKey: (key) -> (event) -> event[key]

  # ### function write (data)
  # #### @data {Object} JSON to output
  # Write `data` to console.
  #
  _transform: (data, encoding, done) ->
    id = @uniqueifier data
    unless id in @ids
      new Chain [
        this
        new @splitter @differentiator, id
        @streamFactory()
      ]
      @ids.push id

    @push data
    done()


module.exports = Split
