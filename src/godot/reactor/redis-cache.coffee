###
redis-cache.js Stream responsible for keeping the current state in Redis
(C) 2016 Charles Phillips
###


Redis   = require "./redis"
errify  = require "errify"
flatten = require "flat"
{unflatten} = flatten


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
class RedisCache extends Redis
  constructor: (options = {}) ->
    super options, @save

    {@id, @redisTtl, @changeTtl} = options
    @id or= "godot2"

  save: (redis, data, callback) ->
    data  = flatten data
    saved = []
    for key, val of data when key isnt "ttl"
      val = JSON.stringify val if key in ["tags"]
      saved.push key, val

    key    = "godot:#{@id}:#{data.host}:#{data.service}:#{data.time}"
    expire = @redisTtl or data.ttl
    ttl    = if @changeTtl then @redisTtl else data.ttl
    multi  = redis.multi()
    multi.hmset key, "ttl", ttl, saved...
         .EXPIRE key, expire
         .exec callback

  #
  # ### function load
  # Loads cache of current keys from Redis
  #
  load: =>
    ideally = errify @error

    await @client.keys "godot:#{@id}:*", ideally defer keys
    multi = @client.multi()
    multi.hgetall key for key in keys
    await multi.exec ideally defer datas
    for data in datas
      data = unflatten data
      continue unless data
      data[key] = JSON.parse data[key] for key in ["tags"] when data[key]
      @push data

    return


module.exports = RedisCache
