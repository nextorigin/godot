###
chain.js: Combine multiple streams in series
(C) 2016 Charles Phillips
###


Combine  = require "stream-combiner2-withopts"

module.exports  = (streams...) ->
  Combine streams..., objectMode: true
