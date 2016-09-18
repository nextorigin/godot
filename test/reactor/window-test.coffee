###
window-test.js: Tests for the *Window and Combine reactor streams.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers")


describe "godot/reactor/window", ->
  fixture    = "by"
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot eventWindow", ->
    describe "{ fixed: true, size: 3 }", ->
      it "should have the appropriate `metric`", (done) ->
        ideally    = errify done
        fixture    = "pings"
        value      = 3
        reactor    = new godot.eventWindow
          fixed: true
          size: 3
        combine    = new godot.combine godot.math.sum
        last       = null

        reactor.pipe combine
        source.pipe reactor
        combine.on "data", (data) -> last = data
        await
          combine.on "end", defer()
          helpers.reactor.writeFixture source, fixture

        expect(last.metric).to.equal value
        done()

    describe "{ fixed: false, size: 1 }", ->
      it.skip "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "pings"
        length     = 3
        reactor    = new godot.eventWindow
          fixed: false
          size: 1

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.reactor.writeFixture source, fixture

        expect(data).to.have.length length
        for set in data
          expect(set).to.have.length 1
        done()

  describe "Godot timeWindow", ->
    describe "{ fixed: true, duration: 1000 }", ->
      it.skip "should have the appropriate `metric`", (done) ->
        ideally    = errify done
        fixture    = helpers.timeSeries {
          service: 'timewindow/test'
          metric: 1
        }, 1000, 100
        value      = 3
        reactor    = new godot.timeWindow
          fixed: true
          duration: 1000
        combine    = new godot.combine godot.math.sum
        last       = null

        reactor.pipe combine
        source.pipe reactor
        combine.on "data", (data) -> last = data
        await
          combine.on "end", defer()
          helpers.reactor.writeFixture source, fixture

        expect(last.metric).to.equal value
        done()

    describe "{ fixed: false, duration: 1000 }", ->
      it.skip "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = helpers.timeSeries {
          service: 'timewindow/test'
          metric: 1
        }, 500, 50
        length     = 1
        reactor    = new godot.timeWindow
          fixed: false
          duration: 500

        source.pipe reactor, end: false
        await
          collect reactor, ideally defer data
          helpers.reactor.writeFixture source, fixture
          setTimeout (reactor.end.bind reactor), 600

        expect(data).to.have.length length
        expect(data[0]).to.have.length 10
        done()
