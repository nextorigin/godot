###
around.js: Stream for piping to multiple independent reactors and passing through values
(C) 2013, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Around (reactor0, reactor1, ...)
# #### @reactor0,...reactorN {godot.reactor().type()*} Reactors to be created
# Constructor function for the thru stream responsible for piping to
# multiple independent reactors.
#
class Around extends stream.PassThrough
  constructor: (@reactors...) ->
    super objectMode: true

    for reactor in @reactors
      throw new Error "This reactor takes a set of reactors" unless reactor instanceof stream.Stream

      @pipe reactor


module.exports = Around
