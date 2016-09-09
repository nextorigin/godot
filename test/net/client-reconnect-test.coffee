###
client-reconnect-test.js: Basic tests for the reconnection of net client.
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"
errify     = require "errify"


godot      = require "../../src/godot"
helpers    = require "../helpers"
mocks      = require "../mocks"


describe "godot/net/client-reconnect", ->
  describe "Godot client", ->
    type      = "tcp"
    format    = "json"
    reconnect =
      retries: 2
      minDelay: 100
      maxDelay: 300
    producers = [
      godot.producer helpers.fixtures["producer-test"]
    ]

    port      = null

    beforeEach ->
      port   = helpers.nextPort

    afterEach ->
      port   = null

    describe "with no backoff and no server", ->
      it "should emit an error", (done) ->
        client = godot.createClient {type, format, producers}

        client.connect port, done
        await client.on "error", defer err
        client.close()

        expect(err).to.be.an.instanceof Error
        done()

    describe "with backoff and no server", ->
      it "should emit an error", (done) ->
        client  = godot.createClient {type, format, producers, reconnect}
        d       = new Date

        client.connect port, done
        await client.on "error", defer err
        client.close()
        time = new Date - d

        expect(err).to.be.an.instanceof Error
        expect(time, "should take appropiate amount of time").to.be.at.least 200
        done()

    describe "with backoff and server eventually coming up", ->
      it "should send data", (done) ->
        ideally = errify done
        client  = godot.createClient {type, format, producers, reconnect}
        d       = new Date

        client.connect port, ideally ->
        client.on "error", done

        await setTimeout defer(), 300
        await mocks.net.createServer {type, port}, ideally defer server
        await server.once "data", defer data
        client.close()
        server.close()
        time = new Date - d

        expect(data).to.exist
        expect(time, "should take appropiate amount of time").to.be.at.least 200
        done()
