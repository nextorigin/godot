###
tagged-any.js: Stream for filtering events with any of a given tag (or set of tags).
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###

Tagged = require "./tagged"
#
# ### function TaggedAny (tags|tag0, tag1, ..., tagN)
# #### @tags|tag0..tagN {Array|arguments} Full set of tags to filter over.
# Constructor function of the TaggedAny stream responsible for filtering
# events with any of a given tag (or set of tags).
#
class TaggedAny extends Tagged
  constructor: ->
    super
    @type = "any"


module.exports = TaggedAny
