Parser = require './Parser'
Entity = require './Entity'

module.exports = class User

  constructor: (@conn, @mud, state) ->
    @currentCmd = ""
    @echo = "full"
    @record = null
    @parser = new Parser()

    conn.on 'data', (message) => @keyhandler(message.charCodeAt(0))
    @changeState state

  keyhandler: (keycode) ->
    switch
      when keycode is 13 
        @mud.states[@state].process this
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
    @mud.states[@state].enter this

  forceQuit: (reason) ->
    @forceQuitReason = reason
    @changeState 'forceQuit'


  createEntity: -> @entity = @mud.entityManager.add @record.entity

  update: ->
    @record.save ->
      console.log 'User record updated'

  updateTick: -> console.log 'User tick update'