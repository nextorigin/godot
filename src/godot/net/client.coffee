#
# * client.js: Client object responsible for managing Producers attached to a TCP or UDP client.
# *
# * (C) 2012, Nodejitsu Inc.
# *
#
events = require "events"
dgram  = require "dgram"
net    = require "net"
tls    = require "tls"
back   = require "back"
ip     = require "ip"
uuid   = require "node-uuid"
utile  = require "utile"
utils  = require "../common/utils"
ndjson = require "ndjson"
{log}  = utils
{noop} = utils
{clone} = utile


#
# ### function Client (options)
# #### @options {Object} Options for this client
# ####   @options.type      {udp|tcp} Networking protocol of this client.
# ####   @options.producers {Array}   Set of producers to get data from.
# ####   @options.host      {string}  Host to send producer data to.
# ####   @options.port      {Number}  Port to send producer data to.
# Constructor function for the Client object responsible for managing
# Producers attached to a TCP or UDP client.
#
class Client extends events.EventEmitter
  #
  # Inherit from EventEmitter
  #

  validTypes: [
    "tcp"
    "tls"
    "udp"
    "unix"
  ]

  validSettings: [
    "type"
    "host"
    "port"
    "path"
    "reconnect"
    "format"
  ]

  validFormats: [
    "json"
  ]

  validate: (options) ->
    unless options?.type in @validTypes
      return "Cannot create client without type: #{@validTypes.join ', '}"

    unless options.format in @validFormats
      return "Cannot create client without format: #{@validFormats.join ', '}"

    unless !options.reconnect or typeof options.reconnect is "object"
      return "Reconnect must be a defined object if used"

  constructor: (options) ->
    throw new Error err if err = @validate options
    super()

    @producers  = {}
    @handlers   = data: {}, end: {}
    @[key]      = options[key] for key in @validSettings
    @host     or= "0.0.0.0"
    @_producers = options.producers
    @attempt    = null

    @defaults =
      host: ip.address()
      state: "ok"
      description: "No Description"
      tags: []
      metric: 1
      meta: {}
      ttl: 15000

    @add producer for producer in @_producers if Array.isArray @_producers

  _writeWhenAvailable: (data) =>
      #
      # Ignore data until we have a socket
      #
      return unless @socket
      @write data
      return

  #
  # ### function add (producer)
  # #### @producer {Producer} Producer to add to this client.
  # Adds the specified `producer` to this client. All data
  # from the producer will be sent over the underlying
  # network connection.
  #
  add: (producer) ->
    id = producer.id or= uuid.v4()
    @producers[id] = producer
    producer.on "data", @handlers.data[id] = @_writeWhenAvailable
    producer.on "end", @handlers.end[id] = => @remove producer, id
    return this

  #
  # ### function remove (producer)
  # #### @producer {producer} Producer to remove from this client.
  # Removes the specified `producer` from this client. All data
  # from the producer will no longer be sent over the underlying
  # network connection.
  #
  remove: (producer, id = producer.id) ->
    producer.removeListener "data", @handlers.data[id]
    producer.removeListener "end", @handlers.end[id]
    delete @producers[id]
    delete @handlers.data[id]
    delete @handlers.end[id]
    return this

  argError: ->
    err = new Error "#{arg} is required to connect"
    return (@callback err) if @callback
    @emit "error", err

  parseArgs: ->
    #
    # Do some fancy arguments parsing to support everything
    # being optional.
    #
    for arg in arguments then switch typeof arg
      when "number"   then port = arg
      when "string"   then host = arg
      when "function" then @callback = arg
    @callback or= noop

    # Split cases due to unix using `this.path`
    switch @type
      when "tcp", "tls", "udp"
        @port = port if port
        return "port" unless @port
        @host = host if host
      when "unix"
        # Equals host due to it being the only string
        @path = host if host
        return "path" unless @path

    return

  _reconnect: (err) ->
    @attempt or= clone @reconnect
    @_lastErr = err
    back @back, @attempt unless @terminate

  fail: ->
    @terminate = true
    @attempt = null
    return @emit "error", @_lastErr

  back: (fail, backoff) =>
    return @fail() if fail
    #
    # So we can listen on when reconnect events are about to fire
    #
    @emit "reconnect", backoff
    @connect()

  socketError: (err) =>
    if @reconnect then @_reconnect err
    else @emit "error", err

  respond: =>
    #
    # Remark: We have successfully connected so reset the terminate variable
    #
    @terminate = false
    @attempt = null
    @emit "connect"
    return

  #
  # ### function connect (callback)
  # #### @port {Number} **Optional** Port number to connect on.
  # #### @host {String} **Optional** Host to connect to.
  # #### @callback {function} **Optional** Continuation to respond to.
  # Opens the underlying network connection for this client.
  #
  connect: (port, host, callback) ->
    return @argError err if err = @parseArgs arguments...

    switch @type
      when "tcp"
        @socket = net.connect {@port, @host}, @callback
      when "tls"
        @socket = tls.connect {@port, @host}, @callback
      when "udp"
        @socket = dgram.createSocket "udp4"
        process.nextTick @callback
      when "unix"
        @socket = net.connect {@path}, @callback

    @socket.on "error", @socketError
    @socket.on "connect", @respond

    return this

  #
  # ### function close ()
  # Closes the underlying network connection for this client.
  #
  close: ->
    @socket.on "close", => @emit "close"

    switch @type
      when "tcp", "tls", "unix" then @socket.destroy()
      else @socket.close()

    @remove producer for producer in @producers
    return this

  createSerializer: ->
    switch @format
      when "json"     then ndjson.stringify()

  _sendOverUDP: (chunk) =>
    @socket.send chunk, 0, chunk.length, @port, @host

  #
  # ### function write (data)
  # #### @data {Object} Data to write.
  # Writes the specified `data` to the underlying network
  # connection associated with this client.
  #
  write: (data) ->
    return unless @socket

    serializer = @createSerializer()

    switch @type
      when "tcp", "tls", "unix"
        serializer.pipe @socket, end: false
      when "udp"
        serializer.once "data", @_sendOverUDP

    serializer.write data
    serializer.end()
    return this

  #
  # ### function produce (data)
  # #### @data {Object|Array} Data to write to socket with some extras
  # Writes to a socket with some default values attached.
  # This is purely a convenience method
  #
  produce: (data = {}) ->

    #
    # Add defaults to each object where a value does not already exist
    #
    defaultify = (obj) ->
      Object.keys(@defaults).reduce ((acc, key) ->
        acc[key] = @defaults[key]  unless acc[key]
        acc
      ), obj

    #
    # TODO: we may want to be monotonic here
    #
    @defaults["time"] = Date.now()
    data = (if Array.isArray data then data.map defaultify else defaultify data)
    @write data


module.exports = Client
