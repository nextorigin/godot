util     = require "util"
stream   = require "readable-stream"
clone    = require "clone"
extend   = util._extend


#
# Pseudo "Socket" like thing to ensure we have a new copy of
# each data event that is written to this. This is passed into the constructor
# of the `reactor`
#
class Socket extends stream.Transform
  constructor: (options) ->
    super extend {objectMode: true}, options

  _transform: (chunk, encoding, callback) ->
    @push clone chunk
    callback() if callback


module.exports = Socket
