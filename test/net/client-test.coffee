###
client-test.js: Basic tests for the net Client module.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


fs         = require "fs"
{expect}   = require "chai"
errify     = require "errify"


godot      = require "../../src/godot"
helpers    = require "../helpers"
mocks      = require "../mocks"

#
# ### function shouldStartServer(options, nested)
# #### @options {Options} Options to setup communication
# ####   @options.type      {udp|tcp} Network protocol.
# ####   @options.port      {number}  Port to communicate over.
# Starts the server with specified options.
#

shouldStartServer = (options, callback) ->
  ideally = errify callback

  await fs.unlink "unix.sock", defer() if options.type is "unix"
  await mocks.net.createServer options, ideally defer server
  callback null, server


describe "godot/net/client", ->
  describe "Godot client", ->
    producers = [
      godot.producer helpers.fixtures["producer-test"]
    ]
    tcp =
      type: "tcp"
      host: "localhost"
      port: helpers.nextPort
      producers: producers

    udp =
      type: "udp"
      host: "localhost"
      port: helpers.nextPort
      producers: producers

    unix =
      type: "unix"
      path: "unix.sock"
      producers: producers

    sockets = {tcp, udp, unix}
    for type, options of sockets then do (type, options) ->
      describe "#{options.type.toUpperCase()} after the server is created", ->
        it "should send data to the server", (done) ->
          ideally = errify done
          client  = godot.createClient options
          client.on "error", done

          await shouldStartServer options, ideally defer server
          await client.connect ideally defer()
          await server.once "data", defer data

          expect(data).to.be.an "object"
          fixture = helpers.fixtures["producer-test"]
          expect(data).to.include.keys "time"
          delete data.time
          expect(fixture).to.eql data

          client.close();

          expect(client.producers).to.be.an "object"
          expect(client.producers).to.be.empty

          done()
