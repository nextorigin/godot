###
duplex-test.js: Basic tests for duplex godot Client/Server communication.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


fs         = require "fs"
{expect}   = require "chai"
errify     = require "errify"


godot      = require "../../src/godot"
helpers    = require "../helpers"


shouldStartServer = (options, callback) ->
  ideally = errify callback
  client  = godot.createClient options

  await fs.unlink "unix.sock", defer() if options.type is "unix"
  await helpers.net.createServer options, ideally defer server
  await client.connect ideally defer()

  expect(server.server).to.be.an "object"
  expect(client.socket).to.be.an "object"

  await server.server.once "message", defer() if options.type is "udp"

  callback null, server, client


describe "godot/net/duplex/multiple", ->
  describe "Godot duplex: tagged", ->
    ttl = 200
    reactors = [
      new godot.taggedAll "a", "b"
    ]
    producers = [
      godot.producer helpers.fixtures["producer-test"]
      godot.producer helpers.fixtures["producer-tagged"]
    ]
    tcp =
      type: "tcp"
      host: "localhost"
      port: helpers.nextPort
      reactors: reactors
      producers: producers
      ttl: ttl

    udp =
      type: "udp"
      host: "localhost"
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
      describe "#{options.type.toUpperCase()} after the server is created", ->
        it "should only receive `a` and `b` tagged events", (done) ->
          ideally = errify done
          await shouldStartServer options, ideally defer server, client
          d            = new Date

          length       = 15
          allData      = []
          hosts        = Object.keys server.hosts
          pairs        = server.hosts[hosts[0]]
          ids          = Object.keys pairs
          taggedStream = pairs[ids[0]].reactor

          await
            onData = (data) ->
              allData.push data
              deferer data if allData.length > length
            taggedStream.on "data", onData
            deferer = defer data
          taggedStream.removeListener "data", onData

          fixture = helpers.fixtures["producer-tagged"]
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
