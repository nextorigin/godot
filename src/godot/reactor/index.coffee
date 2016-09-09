#
# * reactor.js: Top-level include for the `reactors` module responsible processing and reacting to events.
# *
# * (C) 2012, Nodejitsu Inc.
# *
#
fs    = require "fs"
path  = require "path"
utile = require "utile"
{log} = require "../common/utils"

#
# Core files which should not be exported as reactors.
#
core = [
  "index.js"
  "reactor.js"
]

#
# ### function reactor (options)
# #### @options {Object} Options to use when instantiating this reactor
# Creates a new prototypal Reactor for later instantiation.
#
reactor = (godot) ->

  #
  # Register the appropriate reactors
  #
  for file in fs.readdirSync __dirname + "/../../../lib/godot/reactor" when file not in core and (path.extname file) is ".js"
    name    = file.replace /.js$/, ""
    parts   = name.split "-"
    method  = parts[0]
    method += utile.capitalize parts[1] if parts.length > 1

    log "loading reactor #{name}"
    try
      godot[method] = require "./#{name}"
    catch

  console.log "now with coffee"
  for file in fs.readdirSync __dirname + "/../../../src/godot/reactor" when file not in core and (path.extname file) is ".coffee"
    name    = file.replace /.coffee$/, ""
    parts   = name.split "-"
    method  = parts[0]
    method += utile.capitalize parts[1] if parts.length > 1

    log "loading reactor #{name}"
    godot[method] = require "./#{name}"

  return


module.exports = reactor
