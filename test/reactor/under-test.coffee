###
under-test.js: Tests for the Under reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/under", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot under 5", ->

    it "should emit the appropriate events", (done) ->
      ideally    = errify done
      fixture    = "over-under"
      length     = 5
      reactor    = new godot.under 5

      source.pipe reactor
      await
        collect reactor, ideally defer data
        helpers.writeFixture source, fixture

      expect(data).to.have.length length
      done()
