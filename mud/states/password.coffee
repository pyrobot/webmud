bcrypt = require 'bcrypt'

module.exports =
  enter: ->
    @writeln "*{249}Enter your *{255}password*{249}: "
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
          @writeln "*{196}Invalid password.", "*{226}Too many invalid password attempts."
          @changeState 'goodbye'
        else
          @writeln "*{196}Invalid password.", "*{249}Enter your *{255}password*{249}: "

    else
      @writeln "*{249}Enter your *{255}password*{249}: "
