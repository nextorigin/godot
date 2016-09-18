###
meta-test.js: Tests for the Meta reactor stream.
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
macros     = require("../macros").reactor


M1_ALPHA = 1 - Math.exp(-5 / 60)


describe "godot/reactor/meta", ->
  fixture    = helpers.timeSeries {metric: (num) -> num}, 1000, 10
  source     = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot meta", ->
    describe "with a simple movingAverage", ->
      describe "with existing meta", ->
        it "should emit the appropriate events", (done) ->
          ideally    = errify done
          fixture    = helpers.timeSeries {
            meta: foo: "bar"
            metric: (num) -> num
          }, 1000, 10
          length     = 100
          reactor    = new godot.meta "avg", new godot.movingAverage
            average: "simple"
            window: new windowStream.EventWindow size: 10

          source.pipe reactor
          await
            collect reactor, ideally defer data
            helpers.reactor.writeFixture source, fixture

          expect(data).to.have.length length

          for event, i in data
            di  = i + 1
            set = if di < 10 then range(1, di) else range(di - 9, di)
            expect(event.meta).to.be.an "object"
            expect(event.meta.foo).to.equal "bar"

            {avg}  = event.meta
            metset = ({metric: n} for n in set.toArray())
            expect(event.metric).to.equal di
            expect(avg).to.equal godot.math.mean metset

          done()

      describe "with no existing meta", ->
        it "should emit the appropriate events", (done) ->
          ideally    = errify done
          fixture    = helpers.timeSeries {metric: (num) -> num}, 1000, 10
          length     = 100
          reactor    = new godot.meta "avg", new godot.movingAverage
            average: "simple"
            window: new windowStream.EventWindow size: 10

          source.pipe reactor
          await
            collect reactor, ideally defer data
            helpers.reactor.writeFixture source, fixture

          expect(data).to.have.length length

          for event, i in data
            di  = i + 1
            set = if di < 10 then range(1, di) else range(di - 9, di)
            expect(event.meta).to.be.an "object"

            {avg}  = event.meta
            metset = ({metric: n} for n in set.toArray())
            expect(event.metric).to.equal di
            expect(avg).to.equal godot.math.mean metset

          done()

    describe "hasMeta", ->
      describe "all", ->
        describe "with only keys", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 5
            reactor    = new godot.hasMeta "all", "a", "b", "c"

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with all values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 5
            reactor    = new godot.hasMeta "all", a: 1, b: 1, c: 1

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with keys and values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 5
            reactor    = new godot.hasMeta "all", {a: 1}, "b", "c"

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

      describe "any", ->
        describe "with only keys", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 10
            reactor    = new godot.hasMeta "any", "a"

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with all values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 10
            reactor    = new godot.hasMeta "any", a: 1, b: 0, c: 0

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with keys and values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 10
            reactor    = new godot.hasMeta "any", "a", b: 0, c: 0

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

      describe "anyMeta", ->
        describe "with only keys", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 10
            reactor    = new godot.anyMeta "a"

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with all values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 10
            reactor    = new godot.anyMeta a: 1, b: 0, c: 0

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with keys and values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 10
            reactor    = new godot.anyMeta "a", b: 0, c: 0

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

      describe "allMeta", ->
        describe "with only keys", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 5
            reactor    = new godot.allMeta "a", "b", "c"

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with all values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 5
            reactor    = new godot.allMeta a: 1, b: 1, c: 1

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()

        describe "with keys and values", ->
          it "should emit the appropriate events", (done) ->
            ideally    = errify done
            fixture    = "meta"
            length     = 5
            reactor    = new godot.allMeta {a: 1}, "b", "c"

            source.pipe reactor
            await
              collect reactor, ideally defer data
              helpers.reactor.writeFixture source, fixture

            expect(data).to.have.length length
            done()
