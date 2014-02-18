moment = require 'moment'

Parser = require './Parser'
Entity = require './Entity'

idleTimeoutMinutes = 5
idleTimeoutMilliseconds = idleTimeoutMinutes * 60000

module.exports = class User

  constructor: (@conn, @mud, state) ->
    @currentCmd = ""
    @echo = "full"
    @record = null
    @parser = new Parser()
    @loggedIn = false
    @connectTime = moment()

    # helper functions to handle idle timeout
    beginIdleTimeout = => @idleTimeout = setTimeout (=> @forceQuit "Idle for too long."), idleTimeoutMilliseconds
    clearIdleTimeout = => clearTimeout @idleTimeout

    # start the timer
    beginIdleTimeout()

    # register websocket data handler
    conn.on 'data', (message) =>
      clearIdleTimeout()
      @keyhandler(message.charCodeAt(0))
      beginIdleTimeout()

    @changeState state

  keyhandler: (keycode) ->
    switch
      when keycode is 13 
        @mud.states[@state].process.apply this
        @currentCmd = ""
        
      when keycode is 127 
        len = @currentCmd.length
        if len > 0
          @currentCmd = @currentCmd.substr 0, len-1
          @write '\b \b'

      when keycode >= 32 and keycode <= 126
        key = String.fromCharCode keycode
        @currentCmd += key

        switch @echo
          when 'full'
            @write key
          when 'none'
            # do nothing
          else
            @write @echo

  write: (d) -> @conn.write @parser.parse d
  strip: (d) -> @parser.strip d

  writeln: (lines...) ->
    for line in lines
      @write "\r\n#{line}"

  writelnp: (lines...) ->
    lines.push @settings.prompt
    @writeln.apply this, lines

  changeState: (newState) ->
    @state = newState
    @mud.states[@state].enter.apply this

  removeNow: (callback) ->
    @writeln "*{226}You are being removed from the server.\r\n"
    @update =>
      @mud.removeUser this, false
      @conn.end()
      @echo = 'none'
      callback() if callback

  forceQuit: (reason) ->
    @forceQuitReason = reason
    @changeState 'forceQuit'

  createEntity: -> 
    entity = @record.entity.toObject()
    entity.owner = this
    entity.controller = this

    @entity = @mud.addEntity entity

  update: (callback) -> @record?.save -> callback() if callback

  set: (key, val) -> 
    k = key.toLowerCase()
    unless @settings[k] then return @writelnp "The property you are trying to set does not exist."
    @settings[k] = val    
    @writelnp "Setting #{key} to #{val}"

  updateTick: -> console.log 'User tick update'