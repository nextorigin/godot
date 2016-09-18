###
throttle-test.js: Tests for the Throttle reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/throttle", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot throttle", ->
    describe "max", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "large-dataset"
        length     = 10
        reactor    = new godot.throttle 10

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "options", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "large-dataset"
        length     = 10
        reactor    = new godot.throttle max: 10

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()
