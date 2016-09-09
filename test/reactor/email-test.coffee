###
email-test.js: Tests for the Email reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../lib/godot"
helpers    = require("../helpers").reactor
mocks      = require "../mocks"


describe "godot/reactor/email", ->
  describe "Godot email", ->
    source = null

    beforeEach ->
      source = new stream.PassThrough objectMode: true

    afterEach ->
      source = null

    describe "no interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 1
        reactor    = new godot.where "service", "*/health/memory"
        mailer     = new godot.email
          to: "info@health.com"
          from: "health@godot.com"
          subject: "Memory report"
          client: mocks.email

        reactor.pipe mailer
        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "from-to"
        length     = 1
        reactor    = new godot.where "service", "*/health/heartbeat"
        mailer     = new godot.email
          to: "info@health.com"
          interval: 60 * 60 * 1000
          from: "health@godot.com"
          subject: "Memory report"
          client: mocks.email

        reactor.pipe mailer
        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()
