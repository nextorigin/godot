###
rollup-test.js: Tests for the Rollup reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/rollup", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot rollup", ->
    describe "interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 1
        reactor    = new godot.rollup 100

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 100

        expect(data).to.have.length length
        done()

    describe "interval, limit", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.rollup 100, 2

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 300

        expect(data).to.have.length length
        done()

    describe "options", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.rollup
          interval: 100
          limit: 2

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 300

        expect(data).to.have.length length
        done()

    describe "function as interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.rollup ((period) -> period * 100), 2

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 200

        expect(data).to.have.length length
        done()
