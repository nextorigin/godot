/*
 * around-test.js: Tests for the Around reactor stream.
 *
 * (C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
 *
 */

var assert = require('assert'),
    vows = require('vows'),
    godot = require('../../lib/godot'),
    macros = require('../macros').reactor;

var counts = [0, 0, 0],
    over   = 0,
    under  = 0;

//
// Helper function to increment the
// appropriate count.
//
function increment(i) {
  return function (data) {
    counts[i]++;
    return data;
  };
}

var overReactor = new godot.over(5);
overReactor.pipe(new godot.map(function (data) {
  over++;
  return data;
}));

var underReactor = new godot.under(5);
underReactor.pipe(new godot.map(function (data) {
  under++;
  return data;
}));

vows.describe('godot/reactor/around').addBatch({
  "Godot around": {
    "one reactor": macros.shouldEmitDataSync(
        new godot.around(
          new godot.map(increment(0))
        ),
      'by',
      6
    ),
    "two reactors": macros.shouldEmitDataSync(
      new godot.around(
          new godot.map(increment(1)),
          new godot.map(increment(1))
        ),
      'by',
      6
    ),
    "three reactors": macros.shouldEmitDataSync(
      new godot.around(
          new godot.map(increment(2)),
          new godot.map(increment(2)),
          new godot.map(increment(2))
        ),
      'by',
      6
    ),
    "over under": macros.shouldEmitDataSync(
      new godot.around(
          overReactor,
          underReactor
        ),
      'by',
      6
    )
  }
}).addBatch({
  "should emit pipe the events to the correct pipe-chains": function () {
    counts.forEach(function (length, i) {
      assert.equal(length, 6 * (i + 1));
    });

    assert.equal(over, 2);
    assert.equal(under, 4);
  }
}).export(module);