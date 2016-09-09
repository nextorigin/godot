# godot2

[![Build Status][ci-master]][travis-ci]
[![Coverage Status][coverage-master]][coveralls]
[![Dependency Status][dependency]][david]
[![devDependency Status][dev-dependency]][david-dev]
[![Downloads][downloads]][npm-package]

A streaming real-time event processor based on [Riemann][riemann] written in Node.js

[![NPM][npm-stats]][npm-package]

![](https://i.cloudup.com/zCF6jLRpLf.png)

**Godot2** is a major rewrite for Node 6 and Streams2/Streams3 syntax, similar to as suggested in [nodejitsu/godot#64](https://github.com/nodejitsu/godot/issues/64).  The async patterns and inheritance are simplified with Iced CoffeeScript.

Many thanks and much credit to the original authors at Nodejitsu, [@indexzero](https://github.com/indexzero) and [@jcrugzz](https://github.com/jcrugzz).

* [Usage](#usage)
* [Events](#events)
* [Reactors](#reactors)
  * [Primitives](#primitives)
* [Producers](#producers)
* [Tests](#test)

## Usage

Here is a simple example of a [Reactor](#reactors) server that will send an email to `user@host.com` if the [Producer](#producer) server for `app.server` fails to send a heartbeat after 60 seconds.

``` js
  var godot = require('godot');

  //
  // Reactor server which will email `user@host.com`
  // whenever any service matching /.*\/health\/heartbeat/
  // fails to check in after 60 seconds.
  //
  godot.createServer({
    //
    // Defaults to UDP
    //
    type: 'udp',
    reactors: [
      function (socket) {
        return socket
          .pipe(godot.where('service', '*/health/heartbeat'))
          .pipe(godot.expire(1000 * 60))
          .pipe(godot.email({ to: 'user@host.com' }))
      }
    ]
  }).listen(1337);

  //
  // Producer client which sends events for the service
  // `app.server/health/heartbeat` every 15 seconds.
  //
  godot.createClient({
    //
    // Defaults to UDP
    //
    type: 'udp',
    producers: [
      godot.producer({
        host: 'app.server.com',
        service: 'app.server/health/heartbeat',
        ttl: 1000 * 15
      })
    ],
    //
    // Add Reconnect logic that uses `back`
    //
    reconnect: {
      retries: 2,
      minDelay: 100,
      maxDelay: 300
    }
  }).connect(1337);
```

## Events
Similar to [Riemann][riemann], events in `godot` are simply JSON sent over UDP or TCP. Each event has these optional fields:

``` js
  {
    host:         "A hostname, e.g. 'api1', 'foo.com'"
    service:      "e.g. 'API port 8000 reqs/sec'",
    state:        "Any string less than 255 bytes, e.g. 'ok', 'warning', 'critical'",
    time:         "The time of the event, in unix epoch seconds",
    description:  "Freeform text",
    tags:         "Freeform list of strings, e.g. ['rate', 'fooproduct', 'transient']",
    meta:         "Freeform set of key:value pairs e.g. { 'ewma': 12345 }",
    metric:       "A number associated with this event, e.g. the number of reqs/sec.",
    ttl:          "A floating-point time, in seconds, that this event is considered valid for."
  }
```

## Reactors
Reactors in Godot are **readable and writable** [Stream][stream] instances which consume [Events](#events) and produce actions or aggregate data flow. In the example above you may see that when we define the array of reactors by wrapping it with a simple function. This function has a single argument that represents the data coming over the wire. This data can be piped to any `godot` stream or any Transform stream you find on NPM!

~~*Note* Reactors are currently still streams1 streams (so they do not handle backpressure) but this will begin to change in the near future for node `0.12.x`. (Performance reasons)~~ I'm about halfway through this. **-@doublerebel**

### Primitives

There are several core Reactor primitives available in `godot` which can be composed to create more complex behavior:

* `.aggregate()`: Aggregates `metric` property on events
* `.change(key {from: x, to: y})`: Emits events when the key is changed, accepts optional `from` and `to` options for more specific changes.
* `.email(options)`: Sends an email to the specified [options][email-options].
* `.expire(ttl)`: Emits an event when no data is received after `ttl` milliseconds.
* `.forward(options)`: Forwards all events to a remote server located at `options.host` and `options.port`.
* `.sms(options)`: Sends an sms to the specified [options][sms-options].
* `.where(key, value)|.where(filters)`: Filters events based on a single `key:value` pair or a set of `key:value` filters.
* `.rollup(interval, limit)|.rollup(options)`: Rollup a `limit` amount of events to emit every `interval`. `interval` can also be a function to allow you to create varying intervals (see below).

#### Rollup
Here are two possible rollup examples:

```js

var godot = require('godot');

//
// Rolls up 10,0000 events every 5 minute interval
// then sends them in an email
//
var rollup = function (socket) {
  return socket
    .pipe(godot.rollup(1000 * 60 * 5, 10000))
    .pipe(godot.email({ to: 'me@nodejitsu.com' }))
}

//
// Scaling Rollup, rolls up 10,000 events every 5min interval for 1 hour,
// then rolls up 10,000 events every 30mins and emails them out
//

var scalingRollup = function (socket) {
  return socket
    .pipe(godot.rollup(function (period) {
      if(period < 12) {
        return 1000 * 60 * 5;
      }
      return 1000 * 60 * 30;
    }, 10000))
    .pipe(godot.email({ to: 'me@nodejitsu.com' }))
}
```

## Producers
Producers in Godot are **readable** [Stream][stream] instances which produce [Events](#events). Events will be emitted by a given Producer every `ttl` milliseconds.

## Tests

All tests are written in [vows][vows] and can be run with [npm][npm]:

```
  npm test
```

#### Copyright (C) 2012. Charlie Robbins, Jarrett Cruger, and the Contributors.
#### License: MIT

_Sound Wave designed by Alessandro Suraci from the thenounproject.com_

[riemann]: http://aphyr.github.com/riemann/
[stream]: http://nodejs.org/api/stream.html
[email-options]: https://github.com/nodejitsu/godot/tree/master/lib/godot/reactor/email.js
[sms-options]: https://github.com/nodejitsu/godot/blob/master/lib/godot/reactor/sms.js
[npm]: https://npmjs.org
[vows]: http://vowsjs.org/


  [ci-master]: https://img.shields.io/travis/nextorigin/godot2/master.svg?style=flat-square
  [travis-ci]: https://travis-ci.org/nextorigin/godot2
  [coverage-master]: https://img.shields.io/coveralls/nextorigin/godot2/master.svg?style=flat-square
  [coveralls]: https://coveralls.io/r/nextorigin/godot2
  [dependency]: https://img.shields.io/david/nextorigin/godot2.svg?style=flat-square
  [david]: https://david-dm.org/nextorigin/godot2
  [dev-dependency]: https://img.shields.io/david/dev/nextorigin/godot2.svg?style=flat-square
  [david-dev]: https://david-dm.org/nextorigin/godot2?type=dev
  [downloads]: https://img.shields.io/npm/dm/godot2.svg?style=flat-square
  [npm-package]: https://www.npmjs.org/package/godot2
  [npm-stats]: https://nodei.co/npm/godot2.png?downloads=true&downloadRank=true&stars=true
