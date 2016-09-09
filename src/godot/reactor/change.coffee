###
expire.js: Stream for filtering changes to properties on events.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream = require "readable-stream"


#
# ### function Change (key, options)
# #### key {string} Key to detect wether or not its value changes
# #### Options {Object} **optional** Options for specified key
# ####   @from {string} Value you want to set as the base line
# ####   @to   {string}  Value you want to check if it changes to
# Constructor function of the Change stream responsible for filtering events
#
class Change extends stream.Transform
  constructor: (@key, options) ->
    super objectMode: true

    throw new Error "a key is required for this reactor" unless @key

    if options
      @from = options.from or null
      @to = options.to or null

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Watches for changes to the `data` based on
  # the `this.key` this instance is setup
  # to monitor. if `this.from` exists as well as `this.to`,
  # the change case is specified by those two parameters.
  #
  _transform: (data, encoding, done) ->
    changed = false

    # If something changed, see if its a specified case or changed is true
    if @last? and @last isnt data[@key]
      if @from and @to
        if @last is @from and data[@key] is @to
          changed = true
      else
        changed = true

    @last = data[@key]
    if changed
      @push data

    done()


module.exports = Change
