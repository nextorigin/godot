###
has-meta.js: Stream for filtering events with a given meta key (or set of keys).
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function HasMeta ([type], keys|key0, key, ..., keyN)
# #### @type {any|all} Type of tag filtering to perform: any or all.
# #### @keys|key0..keyN {Array|arguments} Full set of keys to filter over.
# Constructor function of the HasMeta stream responsible for filtering
# events with a given meta key (or set of keys).
#
class HasMeta extends stream.Transform
  constructor: (keys...) ->
    super objectMode: true

    [type] = keys
    if type is "any" or type is "all"
      @type = type
      keys  = keys[1..]
    else
      @type = "any"

    #
    # Create a lookup table of any values provided.
    # If no value is provided set the key to `null`
    # since we will be checking for `undefined`.
    #
    @lookup = keys.reduce ((all, key) ->
      if Array.isArray key
        all[k] = null for k in key

      else if typeof key is "object"
        for k, value of key
          all[k] = value

      else
        all[key] = null

      all
    ), {}
    #
    # Store the list of keys for iterating over later.
    #
    @keys = Object.keys @lookup

  #
  # ### function write (data)
  # #### @data {Object} JSON to rollup.
  # Only filters `data` according to `this.keys`.
  #
  _transform: (data, encoding, done) ->
    #
    # If there are no tags on the data return
    #
    return done() unless data.meta

    #
    # Helper function for checking a given `key`.
    #
    hasKey = (key) =>
      data.meta[key]? and (@lookup[key] is null or @lookup[key] is data.meta[key])

    valid = if @type is "all" then (@keys.every hasKey) else (@keys.some hasKey)
    return done() unless valid

    @push data
    done()


module.exports = HasMeta
