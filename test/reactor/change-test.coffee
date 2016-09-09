###
change-test.js: Tests for the Change reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../lib/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/change", ->
  describe "Godot change", ->
    source = null

    beforeEach ->
      source = new stream.PassThrough objectMode: true

    afterEach ->
      source = null

    describe "service", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.change "service"

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "service, from -> to", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "from-to"
        length     = 1
        reactor    = new godot.change "service",
          from: "charlie/app/health/memory"
          to: "charlie/app/health/heartbeat"

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()
