###
within-test.js: Tests for the Within reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


describe "godot/reactor/within", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot within", ->
    it "should emit the appropriate events", (done) ->
      ideally    = errify done
      fixture    = "over-under"
      length     = 3
      reactor    = new godot.within 3, 6

      source.pipe reactor
      await
        collect reactor, ideally defer data
        helpers.writeFixture source, fixture

      expect(data).to.have.length length
      done()

