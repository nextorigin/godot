###
tagged-test.js: Tests for the Tagged, TaggedAny, and TaggedAll reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/tagged", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot tagged", ->
    describe "all", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "tags"
        length     = 5
        reactor    = new godot.tagged 'all', 'a', 'b', 'c'

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "any", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "tags"
        length     = 10
        reactor    = new godot.tagged 'any', 'a'

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "taggedAny", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "tags"
        length     = 10
        reactor    = new godot.taggedAny 'a'

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()

    describe "taggedAll", ->
      it "should emit the appropriate events", (done) ->
        ideally    = errify done
        fixture    = "tags"
        length     = 5
        reactor    = new godot.taggedAll 'a', 'b', 'c'

        source.pipe reactor
        await
          collect reactor, ideally defer data
          helpers.writeFixture source, fixture

        expect(data).to.have.length length
        done()
