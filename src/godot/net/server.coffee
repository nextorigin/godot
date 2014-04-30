#
# * server.js: Server object responsible for managing Producers attached to a TCP or UDP server.
# *
# * (C) 2012, Nodejitsu Inc.
# *
#
dgram      = require "dgram"
events     = require "events"
net        = require "net"
tls        = require "tls"
jsonStream = require "json-stream"
uuid       = require "node-uuid"
Socket     = require "./socket"
common     = require "../common"
{ReadWriteStream} = common
{log} = require "../common/utils"


#
# ### function Server (options)
# #### @options {Object} Options for this server
# ####   @options.type      {udp|tcp} Networking protocol of this server
# ####   @options.reactors  {Array}   Set of reactors to send data to
# ####   @options.port      {Number}  **Optional** Port number to listen on.
# ####   @options.host      {String}  **Optional** Host to listen on.
# ####   @options.multiplex {boolean} **Optional** Value indicating if we should create
#                                     a unique reactor pipe-chain per host.
# Constructor function for the Server object responsible for managing
# an underlying udp or tcp server and piping data to a set of reactors.
#
class Server extends events.EventEmitter
  #
  # Inherit from events.EventEmitter
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
    "multiplex"
    "format"
  ]

  validFormats: [
    "json"
  ]

  validate: (options) ->
    unless options?.type in @validTypes
      return "Cannot create server without type: #{@validTypes.join ', '}"

    unless options.format in @validFormats
      return "Cannot create server without format: #{@validFormats.join ', '}"

  constructor: (options) ->
    err = @validate options
    throw new Error err if err

    events.EventEmitter.call this

    @reactors  = {}
    @hosts     = {}
    @[key]     = options[key] for key in @validSettings
    @host    or= "0.0.0.0"
    @multiplex = true unless @multiplex?
    @_reactors = options.reactors

    log "initalizing #{if @multiplex then 'multiplex ' else ''}godot server"
    @add reactor for reactor in @_reactors if Array.isArray @_reactors
    @createReactors "default" unless @multiplex

  #
  # ### function add (reactor)
  # #### @reactor {reactor} Reactor to add to this server
  # Adds the specified `reactor` to this server. All data
  # from incoming `host:port` pairs will be written to a unique
  # instance of this reactor.
  #
  add: (reactor) ->
    @emit "add", reactor

    #
    # Ok so we have this function that is a `factory` for a reactor
    # or something like that
    #
    reactor.id or= uuid.v4()
    log "adding reactor #{reactor.id}"
    @reactors[reactor.id] = reactor

    #
    # Add reactor to the running set
    # Remark: there will only be one host in case of multiplex = false;
    # Lets special case this so we aren't adding reactors unnecessarily
    # See createReactors function for why
    #
    keys = Object.keys @hosts
    if keys.length
      if @multiplex then for key in keys
        @hosts[key].push @createReactor reactor.id
      else
        @hosts["default"].push @createReactor reactor.id

  #
  # ### function remove (reactor)
  # #### @reactor {reactor} Reactor to remove from this server
  # Removes the specified `reactor` to this server. All data
  # from incoming `host:port` pairs will no longer be written
  # to unique instances of this `reactor`.
  #
  remove: (reactor) ->
    @emit "remove", reactor
    @reactors[reactor.id].socket.removeAllListeners()
    delete @reactors[reactor.id]

    #
    # TODO: Remove this reactor from the running set
    #
    return this

  argError: (arg) ->
    err = new Error "#{arg} is required to listen"
    return (@callback err) if @callback
    @emit "error", err

  parseArgs: (port, host, callback) ->
    #
    # Do some fancy arguments parsing to support everything
    # being optional.
    #
    @callback = null
    for arg in arguments then switch typeof arg
      when "number"   then port = arg
      when "string"   then host = arg
      when "function" then @callback = arg

    # Split cases due to unix using `this.path`
    switch @type
      when "tcp", "tls", "udp"
        @port = port if port
        return "port" unless @port
        @host = host if host
      when "unix"
        # Equals host due to it being the only string
        @path = host
        return "path" unless @path

    return

  respond: (err) =>
    return if responded

    @server.removeListener "error", @respond
    @server.removeListener "listening", @respond
    responded = true
    @emit "listening" unless err
    return (@callback err) if @callback
    @emit "error", err if err

    responded = false

  #
  # ### function listen (port, [host], callback)
  # #### @port {Number} **Optional** Port number to listen on.
  # #### @host {String} **Optional** Host to listen on.
  # #### @callback {function} **Optional** Continuation to respond to.
  # Listens on the underlying networking protocol and pipes
  # all data for each unique `host:port` pair to a set of
  # instantiated reactors.
  #
  listen: (port, host, callback) ->
    err = @parseArgs arguments...
    return @argError err if err

    switch @type
      when "tcp"
        @server = net.createServer @_onTcpSocket
        @server.once "error", @respond
        @server.listen @port, @host, @respond
      when "tls"
        @server = tls.createServer @_onTcpSocket
        @server.once "error", @respond
        @server.listen @port, @host, @respond
      when "udp"
        @server = dgram.createSocket "udp4", @_onUdpMessage
        @server.once "listening", @respond
        @server.once "error", @respond
        @server.bind @port, @host
      when "unix"
        @server = net.createServer @_onUnixSocket
        @server.once "error", @respond
        @server.listen @path, @respond

    return this

  #
  # ### function close (callback)
  # #### @callback {function} Continuation to respond to.
  # Closes the underlying networking protocol.
  #
  close: (callback) ->
    switch @type
      when "tcp", "tls", "unix" then @server.close callback
      else @server.close()

    return this

  #
  # ### function createReactor
  # #### @id {UUID} Reactor id
  # Returns a source and dest stream object that
  # the socket ends up writing to
  #
  createReactor: (id) =>
    log "creating reactor for #{id}"
    socket = new Socket
    socket: socket
    reactor: @reactors[id](socket)

  #
  # ### function createReactors (id)
  # #### @id {string} `host:port` id for these reactors.
  # Instantiates a unique set of reactors for the specified `id`.
  #
  createReactors: (id) ->
    return if @hosts[id]
    log "creating reactors for #{id}"

    #
    # Remark: If we are not creating a new set of streams
    # for each new connection (multiplex = false), then for
    # each new connection, have it point to the default
    # Reactors that were instantiated.
    #
    if @hosts["default"] and not @multiplex
      @hosts[id] = @hosts["default"]
      return this

    @hosts[id] = (@createReactor key for key, val of @reactors)

    return this

  createParser: ->
    switch @format
      when "json"     then jsonStream.parse()

  tellReactors: (id, msg) -> reactor.socket.write msg for reactor in @hosts[id]

  decode: (id, socket) ->
    parser = @createParser()
    @createReactors id

    #
    # Remark: Too much churn here to emit?
    #
    parser.on "data", (event) => @tellReactors id, msg
    socket.setEncoding "utf8"
    socket.pipe parser
    return

  #
  # ### @private function _onUdpMessage (msg, rinfo)
  # #### @msg {String} UDP message.
  # #### @rinfo {Object} Remote address info.
  # Writes the `msg` to the set of instantiated reactors
  # for the `host:port` pair represented by `rinfo.address`
  # and `rinfo.port`.
  #
  _onUdpMessage: (msg, rinfo) =>
    address = rinfo.address
    port    = rinfo.port
    id      = address + ":" + port
    # @decode id, socket

    @createReactors id

    #
    # TODO: Streaming JSON parsing sounds like the right things to do here
    #
    msg = JSON.parse msg.toString().replace "\n", ""
    @tellReactors id, msg
    return

  #
  # ### @private function _onTcpSocket (socket)
  # #### @socket {net.Socket} New incoming socket.
  # Listens for `data` events on the `socket` and writes
  # it to the set of instantiated reactors for the `host:port`
  # pair represented by `socket.remoteAddress` and
  # `socket.remotePort`.
  #
  _onTcpSocket: (socket) =>
    address = socket.remoteAddress
    port    = socket.remotePort
    id      = address + ":" + port
    @decode id, socket

  #
  # ### @private function _onUnixSocket (socket)
  # #### @socket {net.Socket} New incoming socket.
  # Listens for `data` events on the `socket` and writes
  # it to the set of instantiated reactors for the `path`
  # it was instantiated with.
  #
  _onUnixSocket: (socket) =>
    @decode @path, socket


module.exports = Server
