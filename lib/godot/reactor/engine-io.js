/*
 * engine.io.js: Stream responsible for re-emitting data events over engine.io.
 *
 * (C) 2013, Nodejitsu Inc.
 *
 */

var EventEmitter = require('events').EventEmitter,
    utile = require('utile'),
    engine = require('engine.io'),
    ReadWriteStream = require('../common/read-write-stream');

//
// ### function EngineIO (options)
// #### @options {Object} Options for sending email.
// ####   @options.port     {Number} Port for engine.io to listen on.
// ####   @options.host     {String} Optional host to listen on.
// ####   @options.server   {Object} Custom webserver to use.
// Constructor function for the EngineIO stream responsible for re-emitting data
// events over engine.io.
//
var EngineIO = module.exports = function EngineIO(options) {
  if (!options.server && !options.port) {
    throw new Error('options.port or options.server is required');
  }

  var self = this;

  ReadWriteStream.call(this);

  if (options.server) {
    this.server = engine.attach(options.server);
  }
  else {
    this.server = engine.listen(options.port, options.host, options.backlog);
  }

  //
  // Use an event emitter to manage connected sockets
  //
  this._sockets = new EventEmitter();
  this.server.on('connection', function (socket) {

    var listener = function (data) {
      socket.send(data);
    };

    self._sockets.on('data', listener);

    socket.on('close', function () {
      self._sockets.removeListener('data', listener);
    });

  });
};

//
// Inherit from ReadWriteStream.
//
utile.inherits(EngineIO, ReadWriteStream);

//
// ### function write (data)
// #### @data {Object} Data to emit over engine.io.
// Emit the specified data over engine.io.
//
EngineIO.prototype.write = function (data) {
  this._sockets.emit(JSON.stringify(data));
};
