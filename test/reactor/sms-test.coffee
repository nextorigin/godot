###
sms-test.js: Tests for the Sms reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor
mocks      = require "../mocks"


describe "godot/reactor/sms", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot sms", ->
    describe "no interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 1
        reactor    = new godot.where "service", "*/health/memory"
        sms        = new godot.sms
          to: "800OKGODOT"
          from: "800GOGODOT"
          client: mocks.sms

        reactor.pipe sms
        source.pipe reactor
        await
          collect sms, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 1
        reactor    = new godot.where "service", "*/health/heartbeat"
        sms        = new godot.sms
          to: "800OKGODOT"
          interval: 60 * 60
          from: "800GOGODOT"
          client: mocks.sms

        reactor.pipe sms
        source.pipe reactor
        await
          collect sms, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()
