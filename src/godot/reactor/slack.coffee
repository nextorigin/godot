###
slack.js: Stream responsible for sending events to Slack in human-readable form.
(C) 2016 Charles Phillips
###


stream = require "readable-stream"
Notify = require "slack-notify"


#
# ### function Slack (mapFn)
# #### @mapFn {function} Slack function to call on each event.
# #### @options {Object} options to pass into reactor to customize behavior
# Constructor function of the Slack stream responsible for sending
# events to slack in human-readable form.
#
# Also see: https://api.slack.com/methods/chat.postMessage
#
class Slack extends stream.Transform
  constructor: ({@webhook, @channel, @icon_emoji, @username, @text, formatter}) ->
    throw new Error "webhook URL and channel is required." unless @webhook and @channel

    super objectMode: true

    @slack        = Notify @webhook
    @icon_emoji or= ":pager:"
    @username   or= "godot"
    @notify       = @slack.extend {@channel, @icon_emoji, @username, as_user: false}
    @text       or= "Alert:"
    @format       = formatter if formatter

  format: (event) ->
    {@text, fields: event}

  #
  # ### function write (data)
  # #### @data {Object} JSON to filter
  # Emits data after it is mutating with `this.mapFn`.
  #
  _transform: (data, encoding, done) ->
    await @notify (@format data), defer err

    if err then @error err
    else        @push data
    done()

  error: (err) => @emit "error", err


module.exports = Slack
