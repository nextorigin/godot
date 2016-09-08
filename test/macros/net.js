/*
 * net.js: Test macros for godot network communication.
 *
 * (C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
 *
 */

var assert = require('assert'),
    async = require('utile').async,
    helpers = require('../helpers'),
    mocks = require('../mocks'),
    fs = require('fs'),
    godot = require('../../lib/godot');

//
// ### function shouldDuplex (options, nested)
// #### @options {Options} Options to setup full duplex communication
// ####   @options.type      {udp|tcp} Network protocol.
// ####   @options.port      {number}  Port to communicate over.
// ####   @options.ttl       {number}  Default Expiry TTL.
// ####   @options.reactors  {Array}   Set of reactors to use.
// ####   @options.producers {Array}   Set of producers to use.
// #### @nested {Object} Vows context to use once communcation is established.
// Starts a full duplex test run:
//   * Establishes full-duplex communication over the specified
//     `options.type` network protocol on `options.port`, creating
//     the necessary `godot.net.Server` and `godot.net.Client`.
//   * Runs the specified `nested` test context.
//
exports.shouldDuplex = function (options, nested) {
  if (nested && nested.topic) {
    throw new Error('Cannot have topic in top-level of nested context');
  }

  var context = {
    topic: function () {
      var that = this;
      fs.unlink('unix.sock', function () {
        async.series({
          //
          // * Create the `godot.net.Server` instance
          //
          server: async.apply(
            helpers.net.createServer, options
          ),
          //
          // * Create the `godot.net.Client` instance
          //
          client: async.apply(
            helpers.net.createClient, options
          )
        }, function (err, results) {
          if (err) {
            return that.callback(err);
          }

          that.server = results.server;
          that.client = results.client;
          that.callback();
        });
      });
    },
    "should start correctly": function (err, _) {
      assert.isNull(err);
      assert.isTrue(!(_ instanceof Error));
      assert.isObject(this.server);
      assert.isObject(this.server.server);
      assert.isObject(this.client);
      assert.isObject(this.client.socket);
    },
    "after the default TTL": {
      topic: function () {
        setTimeout(this.callback.bind(this), options.ttl);
      },
      "server should have connections and reactors": function () {
        var server = this.server;
        assert.isObject(server.reactors);
        assert.isObject(server.hosts);
      },
      "client should have connection, producers, and handlers": function () {
        var client = this.client;
        assert.isObject(client.producers);
        assert.isObject(client.handlers);
      }
    }
  };

  if (nested) {
    Object.keys(nested).forEach(function (vow) {
      context['after the default TTL'][vow] = nested[vow];
    });
  }

  return context;
};

//
// ### function shouldDuplexAll (options, nested)
// #### @options {Options} Options to setup full duplex communication
// ####   @options.ttl       {number}  Default Expiry TTL.
// ####   @options.reactors  {Array}   Set of reactors to use.
// ####   @options.producers {Array}   Set of producers to use.
// #### @nested {Object} Vows context to use once communcation is established.
// Does the same as `exports.shouldDuplex`, but runs the test over
// TCP UNIX **and** UDP.
//
exports.shouldDuplexAll = function (options, nested) {
  return {
    "TCP": exports.shouldDuplex({
      type: 'tcp',
      ttl: options.ttl,
      port: helpers.nextPort,
      reactors: options.reactors,
      producers: options.producers
    }, nested),
    "UDP": exports.shouldDuplex({
      type: 'udp',
      ttl: options.ttl,
      port: helpers.nextPort,
      reactors: options.reactors,
      producers: options.producers
    }, nested),
    "UNIX": exports.shouldDuplex({
      type: 'unix',
      path: 'unix.sock',
      ttl: options.ttl,
      reactors: options.reactors,
      producers: options.producers
    }, nested)
  };
};
