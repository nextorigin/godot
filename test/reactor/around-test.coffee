###
around-test.js: Tests for the Around reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/around", ->
  counts    = [0, 0, 0]
  #
  # Helper function to increment the
  # appropriate count.
  #
  increment = (i) ->
    (data) ->
      counts[i]++
      data

  describe "Godot around", ->
    fixture    = "by"
    source     = null

    beforeEach ->
      source = new stream.PassThrough objectMode: true

    afterEach ->
      source = null

    describe "one reactor", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 6
        reactor    = new godot.around new godot.map increment 0

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "two reactors", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 6
        reactor    = new godot.around (new godot.map increment 1), (new godot.map increment 1)

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "three reactors", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        length     = 6
        reactor    = new godot.around (new godot.map increment 2), (new godot.map increment 2), (new godot.map increment 2)

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "over under", ->
      it "should pipe the events to the correct pipe-chains", (done) ->
        ideally      = errify done
        length       = 6
        over         = 0
        under        = 0
        overReactor  = new godot.over 5
        overReactor.pipe new godot.map (data) ->
          over++
          data
        underReactor = new godot.under 5
        underReactor.pipe new godot.map (data) ->
          under++
          data
        reactor      = new godot.around overReactor, underReactor

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        for len, i in counts
          expect(len).to.equal 6 * (i + 1)

        expect(over).to.equal 2
        expect(under).to.equal 4
        done()
