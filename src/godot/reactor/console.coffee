###
count.js: Stream responsible for writing messages to the console.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Console (formatFn)
# #### @formatFn {function} Formatting function to use on the data
# Constructor function of the Console stream responsible for writing
# messages to the console.
#
class Console extends stream.Transform
  constructor: (formatFn) ->
    super objectMode: true

    @formatFn = formatFn or console.dir

  # ### function write (data)
  # #### @data {Object} JSON to output
  # Write `data` to console.
  #
  _transform: (data, encoding, done) ->
    @formatFn data
    @push data
    done()


module.exports = Console
