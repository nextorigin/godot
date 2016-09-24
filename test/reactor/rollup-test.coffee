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
        reactor    = new godot.rollup 0.1

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 0.1 * 1000

        expect(data).to.have.length length
        done()

    describe "interval, limit", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.rollup 0.1, 2

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 0.3 * 1000

        expect(data).to.have.length length
        done()

    describe "options", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.rollup
          interval: 0.1
          limit: 2

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 0.3 * 1000

        expect(data).to.have.length length
        done()

    describe "function as interval", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "health"
        length     = 2
        reactor    = new godot.rollup ((period) -> period * 0.1), 2

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 0.2 * 1000

        expect(data).to.have.length length
        done()
