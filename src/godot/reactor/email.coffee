###
email.js: Stream responsible for sending emails on data events.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream   = require "readable-stream"
errify   = require "errify"
SendGrid = require "sendgrid"
helper   = (require "sendgrid").mail


class Sender
  constructor: (@apiKey) ->
    @client = SendGrid @apiKey

  send: ({to, from, subject, text}, callback) ->
    ideally    = errify calback

    from_email = new helper.Email from
    to_email   = new helper.Email to
    content    = new helper.Content 'text/plain', text
    mail       = new helper.Mail from_email, subject, to_email, content
    request    = client.emptyRequest(
      method: 'POST'
      path: '/v3/mail/send'
      body: mail.toJSON())

    client.API request, callback

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

    @body    or= ""
    @subject or= "Godot error for %host%:%service%"
    @client  or= new Sender @auth

  template: (str) ->
    for key, value of @values when key isnt "meta"
      variable = new RegExp "%#{key}%"
      str      = str.replace variable, value.toString()
    str

  #
  # ### function write (data)
  # #### @data {Object} JSON to send email with
  # Sends an email with the specified `data`.
  #
  _transform: (data, encoding, done) ->
    #
    # Return immediately if we have sent an email
    # in a time period less than `this.interval`.
    #
    return done() if @interval and @_last and new Date - (@_last) <= @interval * 1000

    timestamp = (new Date @time).toUTCString()
    subject   = @template @subject
    body      = @template @body
    text      = JSON.stringify data, null, 2
    text      = @timestamp + "\n\n" + @body + "\n\n" + text

    await @client.send {@to, @from, @subject, text}, defer err

    if err then @error err
    else
      @push data
      @_last = new Date
    done()

  error: (err) => @emit "reactor:error", err


module.exports = Email
