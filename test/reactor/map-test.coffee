###
map-test.js: Tests for the Map reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/map", ->
  fixture    = "by"
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot map", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      fixture    = "pings"
      value      = 3
      reactor    = new godot.map (data) ->
        data.metric *= 3
        data
      last       = null

      source.pipe reactor
      reactor.on "data", (data) -> last = data
      await
        reactor.on "end", defer()
        helpers.writeFixture source, fixture

      expect(last.metric).to.equal value
      done()

  describe "Godot map async", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      fixture    = "health"
      value      = 3
      reactor    = new godot.map (data, callback) ->
        data.metric *= 3
        process.nextTick ->
          callback null, data
      last       = null

      source.pipe reactor
      reactor.on "data", (data) -> last = data
      await
        reactor.on "end", defer()
        helpers.writeFixture source, fixture

      expect(last.metric).to.equal value
      done()

  describe "Godot map async, fire and forget async call", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      fixture    = "fireForget"
      value      = 1
      reactor    = new godot.map ((data, callback) ->
        process.nextTick ->
          callback null, data
        ), passThrough: true
      last       = null

      source.pipe reactor
      reactor.on "data", (data) -> last = data
      await
        reactor.on "end", defer()
        helpers.writeFixture source, fixture

      expect(last.metric).to.equal value
      done()

  describe "Godot map error, regular async", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      fixture    = "health"
      reactor    = new godot.map (data, callback) ->
        callback (new Error "ERMAHGERD"), null
      last       = null

      source.pipe reactor
      await
        reactor.once "error", defer err
        helpers.writeFixture source, fixture

      expect(err).to.be.instanceof Error
      done()

  describe "Godot map error, fire and forget", ->
    it "should have the appropriate `metric`", (done) ->
      ideally    = errify done
      fixture    = "fireForget"
      reactor    = new godot.map ((data, callback) ->
        process.nextTick ->
          callback (new Error "ohaithere"), null
        ), passThrough: true
      last       = null

      source.pipe reactor
      await
        reactor.once "error", defer err
        helpers.writeFixture source, fixture

      expect(err).to.be.instanceof Error
      done()
