utils =
  noop: ->

  check: (name, pointer, type) ->
  	return if pointer and typeof pointer is type
  	throw new Error "#{name} #{type} is required."

  log: ->
  	console.log (a.toString() for a in arguments).join ", "

module.exports = utils
