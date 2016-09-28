###
sms.js: Stream responsible for sending SMS messages on data events.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream   = require "readable-stream"
Telenode = require "telenode"
errify   = require "errify"


#
# ### function Sms(options)
# #### @options {Object} Options for sending messages
# ####   @options.auth     {Object} Auth credentials for Twilio.
# ####   @options.from     {string} Phone number to send from.
# ####   @options.to       {string} Phone number to send to.
# ####   @options.body     {string} Body of the SMS to send.
# ####   @options.interval {number} Debounce interval when sending SMSs.
# ####   @options.client   {Object} Custom SMS client to use.
# Constructor function for the Sms stream responsible for sending
# SMS messages on data events.
#
class Sms extends stream.Transform
  constructor: (options) ->
    super objectMode: true

    unless options?.from and options.to and (options.auth or options.client)
      throw new Error "options.auth (or options.client), options.from, and options.to are required"

    @auth     = options.auth
    @to       = options.to
    @from     = options.from
    @interval = options.interval
    @_last    = 0
    #
    # TODO: Support templating of these strings.
    #
    @body     = options.body
    unless options.client
      @client = new Telenode telenode.providers.twilio
      @client.credentials @auth
    else
      @client = options.client

  #
  # ### function write (data)
  # #### @data {Object} JSON to send email with
  # Sends an SMS with the specified `data`.
  #

  _transform: (data, encoding, done) ->
    #
    # Return immediately if we have sent an email
    # in a time period less than `this.interval`.
    #
    return done() if @interval and @_last and (new Date - @_last) <= @interval * 1000

    text    = JSON.stringify data
    sms     = {@from, @to, body: "#{@body} #{text}"}

    await @client.SMS.send sms, defer err

    if err then @error err
    else
      @push data
      @_last = new Date
    done()

  error: (err) => @emit "reactor:error", err


module.exports = Sms
