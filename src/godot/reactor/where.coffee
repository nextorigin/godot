###
where.js: Stream for filtering events based on properties.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream   = require "readable-stream"


#
# ### function Where ([filters|key], target)
# #### @filters {Object} **Optional** Full set of key:value pairs to filter for
# #### @key {string} Key to filter against
# #### @target {string} Value of `key` to filter against.
# Constructor function of the Where stream responsible for filtering events
# based on properties. `new Where(filters)` or `new Where(key, target)` are
# the two ways to instantiate this stream.
#
class Where extends stream.Transform
  constructor: (filters, target, options = {}) ->
    super objectMode: true

    @negate = options.negate or false
    if typeof filters is "object"
      @filters = filters
      @_setFilters filters
    else
      @key = filters
      @_setTarget target

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Filters the specified `data` against `this.key`
  # and `this.value` OR `this.filters`.
  #
  _transform: (data, encoding, done) ->
    value = undefined
    #
    # TODO: Make the negate logic more clear
    #
    if @key
      value = data[@key]
      if @match and @match.test(value) or @isValid and @isValid(value) or @target is value
        @_action data
      else if @negate
        @push data
    else if @filters and @filter(data)
      @_action data
    else if @negate
      @push data

    done()

  #
  # ### function filter (data)
  # #### @data {Object} Event to match against filters.
  # Returns a value indicating whether the specified `data`
  # is valid against `this.filters`.
  #
  filter: (data) ->
    @_filterKeys.every (key) ->
      filter = @_filters[key]
      value  = data[key]
      if filter.match and (filter.match.test value) or filter.isValid and (filter.isValid value) or filter.target is value then true else false

  #
  # ### @private function _action (data)
  # #### @data {Object} data to emit or just ignore
  # Returns an emit event or just returns if the this.negate
  # is set. The negate allows the opposite behavior to take place.
  _action: (data) ->
    if @negate
      return
    @push data

  #
  # ### @private function _setTarget (target, obj)
  # #### @target {function|RegExp|string|number} Target to evaluate against a value
  # #### @obj {Object} Context to set the target against.
  # Sets the matching parameter on the `obj` context based on
  # the `target`.
  #
  _setTarget: (target, obj) ->
    obj = obj or this
    #
    # Allow strings to be converted to RegExps if `*`
    # is found.
    #
    if typeof target is "string" and ~target.indexOf("*")
      target = new RegExp(target.replace("*", "[^\\/]+"))
    if typeof target is "function"
      obj.isValid = target
    else if target.test
      obj.match = target
    else
      obj.target = target
    return

  #
  # ### @private function _setFilters (filters)
  # #### @filters {Object} Mapping of filters to keys
  # Sets the set of matching parameters based on the specified
  # `filters`.
  #
  _setFilters: (filters) ->
    @_filterKeys = Object.keys(filters)
    @_filters = @_filterKeys.reduce(((all, key) ->
      all[key] = {}
      @_setTarget filters[key], all[key]
      all
    ), {})
    return


module.exports = Where
