###
reactor.js: Test helpers for working with reactors.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


helpers = require "./index"
fixtures = helpers.fixtures


#
# ### function writeFixture (stream, name)
# #### @stream {stream.Stream} Stream to write fixture data.
# #### @fixture {string|Array} Name of the fixture (or actual fixture) to write.
# Writes all data in the test fixture with the specified `name`
# to the `stream`.
#
exports.writeFixture = (stream, fixture) ->
  fixture = if typeof fixture is "string" then fixtures[fixture] else fixture
  fixture = JSON.parse(JSON.stringify(fixture))
  stream.write data for data in fixture
  stream.end()

#
# ### function writeFixtureTtl (stream, name, ttl)
# #### @stream {stream.Stream} Stream to write fixture data.
# #### @name {string} Name of the test fixture to write.
# #### @ttl {number} Length of the TTL between events.
# Writes all data in the test fixture with the specified `name`
# to the `stream`.
#
exports.writeFixtureTtl = (stream, name, ttl) ->
  for fixture in fixtures[name]
    stream.write fixture if stream.writable
    await setTimeout defer(), ttl

  stream.end()
