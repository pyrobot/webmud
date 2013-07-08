module.exports = class User
  constructor: (@conn, @mud, state) ->
    conn.on 'data', (message) => @keyhandler(message.charCodeAt(0))
    @changeState state

  currentCmd: ""

  keyhandler: (keycode) =>
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
        @write key

  write: (d) -> @conn.write d

  changeState: (newState) ->
    @state = newState
    @mud.states[@state].enter this 
