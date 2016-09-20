###
meta-split.js: Stream to turn a meta value into a metric value
(C) 2016 Charles Phillips
###


stream = require "readable-stream"
clone  = require "clone"


#
# ### function MetaSplit (tag, reactor)
# #### @key {string} Meta key to turn into the metric.
# Constructor function for the Meta Split stream
#
class MetaSplit extends stream.Transform
  constructor: (@key) ->
    super objectMode: true

  #
  # ### function write (data)
  # Writes the `data` to the meta stream associated
  # with this instance and sets `_metric` so it can
  # be replaced later on.
  #
  _transform: (data, encoding, done) ->
    data = clone data
    data.service += "/#{@key}"
    data.metric   = data.meta[@key]
    @push data
    done()


module.exports = MetaSplit
