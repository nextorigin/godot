{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/mean", ->
  fixture    = "pings"
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot mean", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      value      = 1
      reactor    = new godot.mean()
      last       = null

      source.pipe reactor
      reactor.on "data", (data) -> last = data
      await
        reactor.on "end", defer()
        helpers.writeFixture source, fixture

      expect(last.metric).to.equal value
      done()

