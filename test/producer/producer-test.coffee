###
producer-test.js: Basic tests for the producer module.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


{expect}   = require "chai"


godot      = require "../../lib/godot"
helpers    = require "../helpers"
{Producer} = godot.producer


describe "godot/producer", ->
  describe "Godot producer", ->
    it "should have the correct methods for setting events", ->
      methods = [
        "host"
        "service"
        "state"
        "description"
        "tags"
        "metric"
        "ttl"
        "meta"
      ]
      for method in methods
        expect(Producer::[method]).to.be.a "function"

    describe "when created", ->
      describe "with no values", ->
        producer = null

        beforeEach ->
          producer = godot.producer()

        afterEach ->
          producer = null

        it "should have the correct defaults", ->
          defaults = Producer::defaults
          vals     = producer.values
          delete vals.time
          delete vals.service

          expect(producer.values).to.eql defaults

      describe "with values", ->
        now      = null
        values   = null
        producer = null

        beforeEach ->
          now      = new Date
          values   = helpers.fixtures["producer-test"]
          producer = godot.producer values

        afterEach ->
          now      = null
          values   = null
          producer = null

        it "should set all values", ->
          vals     = producer.values
          delete vals.time

          expect(vals).to.eql values

        it "should set the ttlId", ->
          expect(producer.ttlId).to.be.an "object"
          expect(producer.ttlId.ontimeout or producer.ttlId._onTimeout).to.be.a "function"

        it "should throw when setting invalid data-types", ->
          factory =
            string: -> 0
            number: -> '0'
            array:  -> 0

          for key, type of Producer.prototype.types when key isnt "meta"
            invalid = factory[type]()
            thrower = -> producer[key] invalid
            expect(thrower).to.throw new RegExp "Type mismatch: #{key} must be a #{type}"

        it "should set valid data-types", ->
          for key, _ of Producer.prototype.types
            value = values[key]
            expect(producer[key] value).to.equal producer

        it "should produce on the specified TTL", (done) ->
          await producer.once "data", defer data

          delta = (new Date data.time) - now
          expect(data.time).to.be.a.number
          expect(delta).to.be.at.least values.ttl
          delete data.time

          expect(data, "should produce the correct event").to.eql values
          done()

