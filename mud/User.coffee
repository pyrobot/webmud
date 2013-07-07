module.exports = class User
  constructor: (@conn) ->
    conn.on 'data', (message) => @keyhandler(message.charCodeAt(0))
    @currentCmd = ""

  keyhandler: (keycode) =>
    switch
      when keycode is 13
        if @currentCmd.length > 0
          @conn.write "\r\nYou entered: '#{@currentCmd}'\r\n"
          @currentCmd = ""
        else
          @conn.write "\r\n"

      when keycode is 127 
        if len = @currentCmd.length > 0
          @currentCmd = @currentCmd.substr 0, len-1
          @write '\b \b'

      when keycode >= 32 and keycode <= 126
        key = String.fromCharCode keycode
        @currentCmd += key
        @write key

  write: (d) -> @conn.write d