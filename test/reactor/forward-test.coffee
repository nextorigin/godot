###
forward-test.js: Tests for the Forward rector stream.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

{expect}   = require "chai"
errify     = require "errify"
stream     = require "readable-stream"
collect    = require "collect-stream"

godot      = require "../../src/godot"
helpers    = require("../helpers")


describe "godot/reactor/forward", ->
  source = null

  beforeEach ->
    source = new stream.PassThrough objectMode: true

  afterEach ->
    source = null

  describe "Godot forward", ->
    it "should forward the events to the remote server", (done) ->
      ideally = errify done

      remote     = new godot.where "service", "*/health"
      serverOpts =
        type: "tcp"
        host: "localhost"
        port: 3371
        reactors: [remote]

      await helpers.net.createServer serverOpts, ideally defer server

      reactor = new godot.forward
          type: "tcp"
          host: "localhost"
          port: 3371

      source.pipe reactor
      await setTimeout defer(), 500

      #
      # Get the underlying stream for the connection
      # between the forward reactor and the remote server.
      #
      data = []
      await
        deferred = defer()
        remote.on "data", (somedata) ->
          data.push somedata
          deferred() if data.length is 3
        #
        # Write the test fixture to the local reactor.
        #
        helpers.reactor.writeFixture source, "health"

      expect(data).to.be.an "array"
      expect(data).to.have.length 3
      done()
