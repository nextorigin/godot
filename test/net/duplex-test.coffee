###
duplex-test.js: Basic tests for duplex godot Client/Server communication.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


fs         = require "fs"
{expect}   = require "chai"
errify     = require "errify"


godot      = require "../../src/godot"
helpers    = require "../helpers"
mocks      = require "../mocks"


shouldStartServer = (options, callback) ->
  ideally = errify callback

  await fs.unlink "unix.sock", defer() if options.type is "unix"
  await helpers.net.createServer options, ideally defer server
  await helpers.net.createClient options, ideally defer client

  expect(server.server).to.be.an "object"
  expect(client.socket).to.be.an "object"

  await server.server.once "message", defer() if options.type is "udp"

  callback null, server, client


describe "godot/net/duplex", ->
  describe "Godot duplex", ->
    describe "where & where + expire", ->
      ttl = 200
      whereExpire      = (new godot.where "service", "godot/test").pipe new godot.expire 200
      where            = (new godot.where "service", "godot/test")
      reactors = [
        whereExpire
        where
      ]
      producers = [
        godot.producer helpers.fixtures["producer-test"]
      ]
      tcp =
        type: "tcp"
        port: helpers.nextPort
        reactors: reactors
        producers: producers
        ttl: ttl

      udp =
        type: "udp"
        port: helpers.nextPort
        reactors: reactors
        producers: producers
        ttl: ttl

      unix =
        type: "unix"
        path: "unix.sock"
        reactors: reactors
        producers: producers
        ttl: ttl

      sockets = {tcp, udp, unix}
      for type, options of sockets then do (type, options) ->
        describe "\"where\" reactor", ->
          it "should emit events appropriately", (done) ->
            ideally = errify done
            await shouldStartServer options, ideally defer server, client
            d            = new Date

            await where.once "data", defer data

            fixture = helpers.fixtures["producer-test"]
            expect(data.time, "should emit events appropriately").to.be.a "number"
            delete data.time
            expect(fixture).to.eql data

            d2           = new Date
            remaining    = d2 - d
            await setTimeout defer(), remaining if remaining < options.ttl

            # it "server should have connections and reactors", ->
            expect(server.reactors).to.be.an "object"
            expect(server.hosts).to.be.an "object"

            # it "client should have connection, producers, and handlers", ->
            expect(client.producers).to.be.an "object"
            expect(client.handlers).to.be.an "object"

            server.close()
            done()

        describe "\"where-expire\" reactor", ->
          it "should never expire", (done) ->
            ideally = errify done
            await shouldStartServer options, ideally defer server, client
            d            = new Date

            whereExpire.once "data", -> done "TTL expired incorrectly."
            await setTimeout defer(), 300

            d2           = new Date
            remaining    = d2 - d
            await setTimeout defer(), remaining if remaining < options.ttl

            # it "server should have connections and reactors", ->
            expect(server.reactors).to.be.an "object"
            expect(server.hosts).to.be.an "object"

            # it "client should have connection, producers, and handlers", ->
            expect(client.producers).to.be.an "object"
            expect(client.handlers).to.be.an "object"

            server.close()
            done()
