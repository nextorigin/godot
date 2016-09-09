###
coalesce-test.js: Tests for the Coalesce reactor stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers").reactor


concat = require "concat-stream"
once   = require "once"


collectWithoutFlatten = (stream, fn) ->
  fn = once fn
  stream.on "error", fn
  stream.pipe concat {encoding: "object"}, (data) -> fn null, data


describe "godot/reactor/coalesce", ->
  describe "Godot coalesce", ->
    source = null

    beforeEach ->
      source = new stream.PassThrough objectMode: true

    afterEach ->
      source = null

    it "should emit the appropriate events", (done) ->
      ideally    = errify done
      fixture    = "coalesce"
      length     = 4
      reactor    = new godot.coalesce

      source.pipe reactor
      await
        collectWithoutFlatten reactor, ideally defer data
        helpers.writeFixture source, fixture

      expect(data).to.have.length length
      for len, i in [1, 2, 3, 3]
        expect(data[i]).to.have.length len

      done()


