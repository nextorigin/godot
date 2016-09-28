###
redis.js Stream responsible for storing events in redis
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"
errify = require "errify"
redis  = require "redis"


#
# ### function Redis (options)
# #### @options {Object} Options for sending data to Redis
# ####   @options.host         {String} Host string for redis server
# ####   @options.port         {Number} Port for redis server
# ####   @options.password     {String} Password for redis server
# ####   @options.redisOptions {Object} To override any of the default options
# Constructor function for the Redis Stream responsible for adding events to
# redis
#
class Redis extends stream.Transform
  constructor: (options = {}, redisFn) ->
    super objectMode: true

    @client  = options.client
    @redisFn = redisFn

    # Check if client was passed in
    unless @client
      @client = redis.createClient options
      @client.on "error", @error

  #
  # ### function write (data)
  # #### @data {Object} JSON to store in Redis
  # Uses Redis to track active resources using a bitmap
  #
  _transform: (data, encoding, done) ->
    ideally = errify (err) =>
      @error err
      done()

    await @redisFn @client, data, ideally defer data
    @push data
    done()

  error: (err) =>
    @emit "error", err


module.exports = Redis
