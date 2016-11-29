###
forward.js: Stream for forwarding events to another remote server.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
uuid   = require "node-uuid"
Client = require "../net/client"


#
# ### function Forward (options)
# #### @options {Object} Options for forwarding events.
# ####   @options.type {tcp|udp} Networking protocol to use.
# ####   @options.host {string} Remote host to forward to.
# ####   @options.port {number} **Optional** Remote port to forward to.
# Constructor function of the Forward stream responsible for forwarding
# events to another remote server.
#
class Forward extends stream.PassThrough
  validSettings: [
    "type"
    "host"
    "port"
  ]

  validate: (options) ->
    for setting in @validSettings
      unless options?[setting]?
        return "Cannot create client without setting: #{setting}"

  constructor: (options) ->
    throw new Error err if err = @validate options
    super objectMode: true

    clientOpts =
      producers: [this]
    clientOpts[setting] = options[setting] for setting in Client::validSettings when options[setting]?
    @id     = uuid.v4()
    @client = new Client clientOpts
    @client.connect()

  #
  # Remark: No need for a `write` method here because this instance
  # simply emits `data` events (by inheriting from ReadWriteStream)
  # with are automatically sent to `this.client`.
  #
  #
  # ### function end (data)
  # Emits the "end" event and closes the underlying
  # client connection.
  #
  end: ->
    @emit "end"
    @client.close() if @client


module.exports = Forward
