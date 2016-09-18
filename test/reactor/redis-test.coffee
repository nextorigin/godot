###
# redis-test.js: Tests for the Redis reactor stream
#
# (C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
#
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor
mocks      = require "../mocks"


describe "godot/reactor/redis", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot redis", ->

    it "should emit the appropriate events", (done) ->
      ideally    = errify done
      fixture    = "health"
      length     = 1
      reactor    = new godot.where 'service', '*/health/memory'
      redis      = new godot.redis {client: mocks.redis}, (client, data, callback) ->
        # Do something with redis of your choosing
        process.nextTick ->
          callback null, data

      reactor.pipe redis
      source.pipe reactor
      await
        collect reactor, ideally defer data
        helpers.writeFixture source, fixture

      expect(data).to.have.length length
      done()
