###
index.js: Top-level include for the `producers` module responsible creating events to process.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

#
# ### function producer (options)
# #### @options {Object} Options to use when instantiating this producer
# Creates a new producer for emitting events to process.
#
producer = module.exports = (options) ->
  new producer.Producer options

#
# ### @Producer {Object}
# Base Prototype for the Producer.
#
producer.Producer = require "./producer"
