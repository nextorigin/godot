#
# * reactor.js: Top-level include for the `reactors` module responsible processing and reacting to events.
# *
# * (C) 2012, Nodejitsu Inc.
# *
#
fs    = require "fs"
path  = require "path"


camelize = (str) ->
  ((str.split /[\W_-]/).map capitalize).join ""

capitalize = (str) ->
  str[0].toUpperCase() + str[1..]

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
  for file in fs.readdirSync __dirname when file not in core and ((path.extname file) is ".js") or ((path.extname file) is ".coffee")
    name    = file.replace /(.js|.coffee)$/, ""
    parts   = name.split "-"
    method  = parts[0]
    method += (parts[1..].map camelize).join "" if parts.length > 1

    godot[method] = require "./#{name}"


module.exports = reactor
