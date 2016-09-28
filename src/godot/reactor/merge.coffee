###
merge.js: Merge multiple readable streams into a single source and passthrough (the other side of Around)
(C) 2016 Charles Phillips
###


{Merge}  = require "stream-combiner2-withopts"

module.exports  = (streams...) ->
  Merge streams..., objectMode: true
