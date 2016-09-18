###
tag-test.js: Tests for the Tag reactor stream.
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


describe "godot/reactor/tag", ->
  fixture    = helpers.timeSeries {metric: (num) -> num}, 1000, 10
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot tag", ->
    describe "with a simple movingAverage", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 100
        reactor    = new godot.tag "avg", new godot.movingAverage
          average: "simple"
          window: new windowStream.EventWindow size: 10

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.reactor.writeFixture source, fixture

        expect(data).to.have.length length

        for event, i in data
          di  = i + 1
          expect(event.metric).to.equal di

          set = if di < 10 then (range 1, di) else (range di - 9, di)
          metset = ({metric: n} for n in set.toArray())
          avg = do -> return tag for tag in event.tags when tag.match /avg/
          avg = parseFloat (avg.split ':')[1], 10
          expect(avg).to.equal godot.math.mean metset

        done()
