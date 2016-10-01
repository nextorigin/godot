###
redis-cache.js Stream responsible for keeping the current state in Redis
(C) 2016 Charles Phillips
###


Redis       = require "./redis"
Producer    = require "../producer/producer"
errify      = require "errify"
flatten     = require "flat"
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

    {@id, @ttl, @changeTtl} = options
    @id         or= "godot2"
    SortedCache   = require "redis-sorted-cache"
    @cache        = new SortedCache {redis: @client, name: @id, @ttl}

  save: (redis, data, callback) ->
    ideally = errify callback

    data  = flatten data
    saved = []
    for key, val of data when key isnt "ttl"
      val = JSON.stringify val if key in ["tags"]
      saved.push key, val

    key    = "godot:#{@id}:#{data.host}:#{data.service}:#{data.time}"
    expire = @ttl or data.ttl
    ttl    = if @changeTtl then @ttl else data.ttl

    multi  = redis.multi()
    multi.hmset key, "ttl", ttl, saved...
         .EXPIRE key, expire
    await multi.exec ideally defer()
    @cache.addToSet key, data.time, callback

  #
  # ### function load
  # Loads cache of current keys from Redis
  #
  load: =>
    ideally = errify @error

    await @cache.keys ideally defer keys
    multi = @client.multi()
    multi.hgetall key for key in keys
    await multi.exec ideally defer datas

    for data in datas
      data = unflatten data
      continue unless data
      types     = Producer::types
      data[key] = JSON.parse data[key] for key, type of types when data[key] and typeof data[key] isnt type
      @push data

    return


module.exports = RedisCache
