###
tagged.js: Stream for filtering events with a given tag (or set of tags).
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Tagged ([type], tags|tag0, tag1, ..., tagN)
# #### @type {any|all} Type of tag filtering to perform: any or all.
# #### @tags|tag0..tagN {Array|arguments} Full set of tags to filter over.
# Constructor function of the Tagged stream responsible for filtering
# events with a given tag (or set of tags).
#
class Tagged extends stream.Transform
  constructor: (tags...) ->
    super objectMode: true

    [type] = tags
    if type is "any" or type is "all"
      @type = type
      tags.splice 0, 1
    else
      @type = "any"

    @tags = tags.reduce ((all, tags) ->
      if Array.isArray tags then all = all.concat tags
      else                       all.push tags
      all), []

  # ### function write (data)
  # #### @data {Object} JSON to rollup.
  # Only filters `data` according to `this.tags`.
  #
  _transform: (data, encoding, done) ->
    #
    # If there are no tags on the data return
    #
    return done() unless data.tags?.length

    #
    # Helper function for checking a given `tag`.
    #
    hasTag = (tag) -> tag in data.tags

    valid = if @type is "all" then (@tags.every hasTag) else (@tags.some hasTag)
    return done() unless valid

    @push data
    done()


module.exports = Tagged
