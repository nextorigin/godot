###
email.js: Stream responsible for sending emails on data events.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream   = require "readable-stream"
SendGrid = require "sendgrid-web"

#
# ### function Email (options)
# #### @options {Object} Options for sending email.
# ####   @options.auth     {Object} Auth credentials for SendGrid.
# ####   @options.from     {string} Email address to send from.
# ####   @options.to       {string} Email address to send to.
# ####   @options.body     {string} Body of the email to send.
# ####   @options.subject  {string} Subject of the email to send.
# ####   @options.interval {number} Debounce interval when sending emails.
# ####   @options.client   {Object} Custom email client to use.
# Constructor function for the Email stream responsible for sending
# emails on data events.
#
class Email extends stream.Transform
  constructor: ({@auth, @from, @to, @body, @subject, @client, @interval}) ->
    super objectMode: true

    if !@from or !@to or !@auth and !@client
      throw new Error "options.auth (or options.client), options.from, and options.to are required"

    @_last = 0
    #
    # TODO: Support templating of these strings.
    #
    @body    or= ""
    @subject or= "Godot error"
    @client  or= new SendGrid @auth

  #
  # ### function write (data)
  # #### @data {Object} JSON to send email with
  # Sends an email with the specified `data`.
  #
  _transform: (data, encoding, done) ->
    text = JSON.stringify data, null, 2
    #
    # Return immediately if we have sent an email
    # in a time period less than `this.interval`.
    #
    return if @interval and @_last and new Date - (@_last) <= @interval

    text = @body + "\n\n" + text
    await @client.send {@to, @from, @subject, text}, defer err

    @_last = new Date

    if err then @emit "reactor:error", err
    else        @push data
    done()


module.exports = Email
