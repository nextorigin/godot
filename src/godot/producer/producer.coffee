###
producer.js: Producer object responsible for creating events to process.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
ip     = require "ip"
util   = require "util"
extend = util._extend
tick   = if typeof setImmediate is "undefined" then process.nextTick else setImmediate


# #### @options {Object} Options for this producer.
# Constructor function for the Producer object responsible
# for creating events to process.
#
class Producer extends stream.PassThrough
  constructor: (options = {}, streamOptions = {}) ->
    super extend {objectMode: true}, streamOptions

    @values = {}
    #
    # Set the defaults for this instance.
    #
    for key, _ of @types when key isnt "ttl"
      @[key] options[key] or @defaults[key]
    #
    # Set the TTL
    #
    ttl = if typeof options.ttl is "number" then options.ttl else @defaults.ttl
    @ttl ttl

    @_streaming = options.streaming

  #
  # ### @defaults {Object}
  # Default values for properties on events
  # emitted by this instance.
  #
  defaults:
    host:           ip.address()
    state:          "ok"
    description:    "No description"
    tags:           []
    metric:         1
    ttl:            15000

  #
  # ### @types {Object}
  # Types for properties on events emitted by
  # this instance.
  #
  types:
    host:           "string"
    service:        "string"
    state:          "string"
    description:    "string"
    time:           "number"
    tags:           "array"
    metric:         "number"
    ttl:            "number"
    meta:           "object"

  #
  # ### function host|service|state|description|tags|metric (value)
  # #### @value {string|number} Value to set for the specified key.
  # Sets the specified `key` on data produced by this instance.
  #
  for key, _ of Producer::types then do (key) ->

    Producer::[key] = (value) ->
      type      = Producer::types[key]
      valueType = typeof value

      #
      # Only set the key on this instance if the typeof `value`
      # matches expected type. Allow for undefined values.
      #
      if type is "array" and Array.isArray(value) or type is valueType or valueType is "undefined"
        #
        # Only set the TTL if it has a real value that is
        # different from the current TTL.
        #
        if key is "ttl" and typeof value is "number" and value isnt @values.ttl

          #
          # If the ttl is set to zero then pummell emit data
          #
          if value is 0
            tickProduce = ->
              tick ->
                self.produce()
                tickProduce()
            tickProduce()

          unless @_streaming
            if @ttlId
              clearInterval @ttlId
            @ttlId = setInterval (=> @produce()), value

        @values[key] = value
        return this

      else
        #
        # Throw an error if there is a type mismatch.
        #
        throw new Error("Type mismatch: " + key + " must be a " + type)

  #
  # ### function produce ()
  # Emits the data for this instance
  #
  produce: ->
    @push
      host:          @values.host
      service:       @values.service
      state:         @values.state
      time:          Date.now()
      description:   @values.description
      tags:          @values.tags
      metric:        @values.metric
      ttl:           @values.ttl
      meta:          @values.meta


module.exports = Producer
