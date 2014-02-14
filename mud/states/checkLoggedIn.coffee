bcrypt = require 'bcrypt'

module.exports =
  enter: ->
    unless @mud.userLoggedIn @foundUser.name
      @changeState 'password'
    else
      @writeln "User is already logged in.", "*{249}Enter your *{255}password*{249} to take over session: "
      @echo = '*'
      @badPassword = 0

  process: ->
    if @currentCmd.length > 0
      pw = @currentCmd

      if bcrypt.compareSync(pw, @foundUser.hash)
        # check if the user is already logged in
        currentLoggedInUser = @mud.getUserByName @foundUser.name

        # force quit the other session
        if currentLoggedInUser
          currentLoggedInUser.removeNow =>
            @name = @foundUser.name
            @changeState 'enterGame'
        else
          @changeState 'enterGame'
      else
        @badPassword++
        
        if @badPassword >= 3
          @writeln "*{196}Invalid password.", "*{226}Too many invalid password attempts."
          @changeState 'goodbye'
        else
          @writeln "*{196}Invalid password.", "*{249}Enter your *{255}password* to take over session{249}: "

    else
      @writeln "*{249}Enter your *{255}password*{249} to take over session: "
