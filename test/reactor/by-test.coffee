###
by-test.js: Tests for the By reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../lib/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/by", ->
  fixture = "by"

  describe "Godot by", ->
    counts =
      service: 0
      "service+ttl": 0
      "service+recombine": 0

    source = null

    beforeEach ->
      source = new stream.PassThrough objectMode: true

    afterEach ->
      source = null

    describe "service", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 6
        subreactor = new godot.map (data) ->
          counts.service++
          data
        reactor    = new godot.by "service", subreactor

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "[service, ttl]", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 6
        subreactor = new godot.map (data) ->
          counts["service+ttl"]++
          data
        reactor    = new godot.by ["service", "ttl"], subreactor

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "service, recombine", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 12
        subreactor = new godot.map (data, callback) ->
          counts["service+recombine"]++
          #
          # Calling `callback` twice will cause `data` event to be emitted
          # twice on the `Map` stream, thus resulting in doubling each
          # message.
          #
          callback null, data
          callback null, data
        reactor    = new godot.by "service", subreactor, recombine: true

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "finally", ->
      it "should emit and pipe the events to the correct pipe-chains", ->
        expect(counts.service).to.equal 6
        expect(counts["service+ttl"]).to.equal 12
        expect(counts["service+recombine"]).to.equal 6
