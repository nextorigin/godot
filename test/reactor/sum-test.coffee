###
sum-test.js: Tests for the Sum reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/sum", ->
  fixture    = "by"
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot sum", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      fixture    = "pings"
      value      = 3
      reactor    = new godot.sum
      last       = null

      source.pipe reactor
      reactor.on "data", (data) -> last = data
      await
        reactor.on "end", defer()
        helpers.writeFixture source, fixture

      expect(last.metric).to.equal value
      done()
