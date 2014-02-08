bcrypt = require 'bcrypt'

module.exports =
  enter: (user) ->
    unless user.mud.userLoggedIn user.foundUser.name
      user.changeState 'password'
    else
      user.write "\r\nUser is already logged in.\r\n*{249}Enter your *{255}password*{249} to take over session: "
      user.echo = '*'
      user.badPassword = 0

  process: (user) ->
    if user.currentCmd.length > 0
      pw = user.currentCmd

      if bcrypt.compareSync(pw, user.foundUser.hash)
        currentLoggedInUser = user.mud.getUserByName user.foundUser.name
        if currentLoggedInUser
          # copy the current logged in user data into this user
          user.record = currentLoggedInUser.record
          user.entity = currentLoggedInUser.entity
          user.name = currentLoggedInUser.name

          # force quit the other session
          currentLoggedInUser.forceQuit 'Logged in from different session.'

          user.changeState 'continueGame'
        else
          user.changeState 'enterGame'
      else
        user.badPassword++
        
        if user.badPassword >= 3
          user.write "\r\n*{196}Invalid password.\r\n*{226}Too many invalid password attempts."
          user.changeState 'goodbye'
        else
          user.write "\r\n*{196}Invalid password.\r\n*{249}Enter your *{255}password* to take over session{249}: "

    else
      user.write "\r\n*{249}Enter your *{255}password*{249} to take over session: "
