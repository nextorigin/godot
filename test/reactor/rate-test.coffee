###
rate-test.js: Tests for the Rate reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/rate", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot rate", ->

    it "should emit the appropriate events", (done) ->
      ideally    = errify done
      fixture    = "pings"
      length     = 1
      reactor    = new godot.rate 0.05

      source.pipe reactor, end: false
      await
        collect reactor, ideally defer data
        helpers.writeFixture source, fixture
        setTimeout (reactor.end.bind reactor), 0.06 * 1000

      expect(data).to.have.length length
      expect(data[0].metric).to.equal 1
      done()
