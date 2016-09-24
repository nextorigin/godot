/*
 * reactor.js: Starts a single reactor with options passed over child IPC.
 *
 * (C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
 *
 */

var godot = require('../../../lib/godot'),
    helpers = require('../index');

//
// Starts the reactor server
//
function start(options) {
  helpers.net.createServer({
    type:      options.type,
    port:      options.port,
    multiplex: options.multiplex || false,
    reactors:  [
      function (socket) {
        socket
          .pipe(godot.count(options.interval || options.duration))
          .pipe(godot.console(function (data) {
            console.log([
              '',
              'Received:',
              '  ' + data.metric + ' total messages',
              '  ' + data.metric/options.duration + ' per second'
            ].join('\n'));
          }))
      }
    ]
  }, function (err) {
    return err
      ? process.send({ error: err })
      : process.send({ started: true });
  });
}

process.once('message', start);
