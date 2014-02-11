bcrypt = require 'bcrypt'

module.exports =
  enter: ->
    @write "\r\n*{249}Enter your *{255}password*{249}: "
    @echo = '*'
    @badPassword = 0

  process: ->
    if @currentCmd.length > 0
      pw = @currentCmd

      if bcrypt.compareSync(pw, @foundUser.hash)
        @name = @foundUser.name
        @changeState 'enterGame'
      else
        @badPassword++
        
        if @badPassword >= 3
          @write "\r\n*{196}Invalid password.\r\n*{226}Too many invalid password attempts."
          @changeState 'goodbye'
        else
          @write "\r\n*{196}Invalid password.\r\n*{249}Enter your *{255}password*{249}: "

    else
      @write "\r\n*{249}Enter your *{255}password*{249}: "
