###
expire-test.js: Tests for the Expire reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/expire", ->
  describe "Godot aggregate, ttl 0.1s", ->
    source = null

    beforeEach ->
      source = new stream.PassThrough objectMode: true

    afterEach ->
      source = null

    describe "sent 0.2s", ->
      it "should get expired event", (done) ->
        ideally    = errify done
        fixture    = "health"
        reactor    = new godot.expire 0.1

        source.pipe reactor
        await
          reactor.on "data", defer data
          helpers.writeFixtureTtl source, fixture, 0.2

        expect(data).to.be.an "object"
        expect(reactor.readable).to.be.true
        done()

    describe "sent 0.05s", ->
      it "should not expire", (done) ->
        ideally    = errify done
        fixture    = "health"
        reactor    = new godot.expire 0.1

        source.pipe reactor
        await
          reactor.on "data", -> done new Error "Did expire"
          reactor.on "end", defer()
          helpers.writeFixtureTtl source, fixture, 0.05

        expect(reactor).to.be.an.instanceof stream.Stream
        done()
