###
# graphite.js: Stream responsible for sending metrics on data events to graphite.
#
# @obazoud
#
# Important: set mulitplex to false to create only one Graphite client
#
# godot.createServer({
#   type: "tcp",
#   multiplex: false,
#   reactors: [
#     godot.reactor()
#       .graphite({
#         url: "plaintext://carbon.hostedgraphite.com:2003",
#         prefix: "xxxx.godot",
#        })
#       .console()
#   ]
# }).listen(1337);
#
###


util     = require "util"
stream   = require "readable-stream"
graphite = require "graphite"
errify   = require "errify"


#
# ### function Graphite (options)
# #### @options {Object} Options for sending data to Graphite.
# ####   @options.url      {string} Graphite url.
# ####   @options.prefix   {string} Graphite prefix added to all metrics.
# Constructor function for the Graphite stream responsible for sending
# metrics on data events.
#
Graphite =
class Map extends stream.Transform
  constructor: (options) ->
    throw new Error "options.url and options.prefix are required" unless options?.url and options.prefix

    super objectMode: true

    @url      = options.url
    @prefix   = options.prefix or "godot"
    @interval = options.interval or 60
    @meta     = options.meta or null
    @_last    = 0
    @client   = options.client or graphite.createClient(@url)

  #
  # ### function write (data)
  # #### @data {Object} JSON to send metric with
  # Sends a metric with the specified `data`.
  #
  _transform: (data, encoding, done) ->
    ideally    = errify (err) => @emit "reactor:error", err
    now        = new Date
    metrics    = {}
    metricName = undefined
    #
    # Return immediately if we have sent a metric
    # in a time period less than `this.interval`.
    #
    return done() if @interval and @_last and (now - @_last) <= @interval * 1000

    metricName          = util.format "%s.%s.%s",
      @prefix,
      data.host.replace(/\./g, "_"),
      data.service.replace(/\./g, "_").replace /\//g, "."
    metrics[metricName] = if @meta then data.meta[@meta] else data.metric

    await @client.write metrics, data.time, ideally defer()
    @_last = now
    @push data
    done()


module.exports = Graphite
