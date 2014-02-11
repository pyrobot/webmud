Parser = require './Parser'
Entity = require './Entity'

module.exports = class User

  constructor: (@conn, @mud, state) ->
    @currentCmd = ""
    @echo = "full"
    @record = null
    @parser = new Parser()
    @loggedIn = false

    conn.on 'data', (message) => @keyhandler(message.charCodeAt(0))
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

  changeState: (newState) ->
    @state = newState
    @mud.states[@state].enter.apply this

  removeNow: (callback) ->
    @write "\r\n*{226}You are being removed from the server.\r\n"
    @update =>
      @mud.removeUser this, false
      @conn.end()
      @echo = 'none'
      callback() if callback

  forceQuit: (reason) ->
    @forceQuitReason = reason
    @changeState 'forceQuit'

  createEntity: -> @entity = @mud.entityManager.add @record.entity

  update: (callback) -> @record?.save -> callback() if callback      

  updateTick: -> console.log 'User tick update'