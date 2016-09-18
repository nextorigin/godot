###
moving-average-test.js: Tests for the MovingAverage reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"

range      = require "r...e"
windowStream = require "window-stream"

helpers    = require "../helpers"


M1_ALPHA = 1 - Math.exp(-5 / 60)


describe "godot/reactor/moving-average", ->
  fixture    = helpers.timeSeries {metric: (num) -> num}, 1000, 10
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot movingAverage", ->
    describe "simple", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 100
        reactor    = new godot.movingAverage
          average: "simple"
          window: new windowStream.EventWindow size: 10

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.reactor.writeFixture source, fixture

        expect(data).to.have.length length

        for event, i in data
          di  = i + 1
          set = if di < 10 then (range 1, di) else (range di - 9, di)
          metset = ({metric: n} for n in set.toArray())
          expect(event.metric).to.equal godot.math.mean metset

        done()

    describe "weighted", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 100
        reactor    = new godot.movingAverage
          average:
            type: "weighted"
            weights: [0, 0, 0, 0, 0,
                      0, 0, 0, 0, 1]
          window: new windowStream.EventWindow size: 10

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.reactor.writeFixture source, fixture

        expect(data).to.have.length length

        for event, i in data
          di = i + 1
          divisor = if di < 10 then di else 10
          expect(event.metric).to.equal di / (divisor * (divisor + 1) / 2)

        done()

    describe "exponential", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 100
        reactor    = new godot.movingAverage
          average: "exponential"
          alpha: M1_ALPHA
          window: new windowStream.EventWindow size: 10

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.reactor.writeFixture source, fixture

        expect(data).to.have.length length
        done()
