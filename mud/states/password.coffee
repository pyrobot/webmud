bcrypt = require 'bcrypt'

module.exports =
  enter: (user) ->
    user.write "\r\n*{249}Enter your *{255}password*{249}: "
    user.echo = '*'
    user.badPassword = 0

  process: (user) ->
    if user.currentCmd.length > 0
      pw = user.currentCmd

      if bcrypt.compareSync(pw, user.foundUser.hash)
        user.name = user.foundUser.name
        user.changeState 'enterGame'
      else
        user.badPassword++
        
        if user.badPassword >= 3
          user.write "\r\n*{196}Invalid password.\r\n*{226}Too many invalid password attempts."
          user.changeState 'goodbye'
        else
          user.write "\r\n*{196}Invalid password.\r\n*{249}Enter your *{255}password*{249}: "

    else
      user.write "\r\n*{249}Enter your *{255}password*{249}: "
