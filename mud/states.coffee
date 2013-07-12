commands = require './commands'
bcrypt = require 'bcrypt'

module.exports = states =
  connect:
    enter: (user) ->
      user.write user.mud.config.messages.connectBanner
      user.changeState 'login'

  login:
    enter: (user) ->
      user.write user.mud.config.messages.enterUsername

    process: (user) ->
      if user.currentCmd.length > 0
        name = user.currentCmd.split(' ')[0]
        name = name[0...1].toUpperCase() + name[1..].toLowerCase()
        if name.length < 3 or name.length > 12
          user.write "\r\n#{user.mud.config.messages.nameLengthError}\r\n#{user.mud.config.messages.enterUsername}"
        else unless (/^[a-zA-Z]+$/).exec(name)
          user.write "\r\n#{user.mud.config.messages.invalidCharactersError}\r\n#{user.mud.config.messages.enterUsername}"
        else
          query = user.mud.db.User.findOne({name: name})

          query.exec (err, foundUser) ->
            if foundUser
              user.foundUser = foundUser
              user.changeState 'password'
            else
              user.confirmName = name
              user.changeState 'confirm'

      else
        user.write "\r\n#{user.mud.config.messages.enterUsername}"

  password:
    enter: (user) ->
      user.write "\r\n#{user.mud.config.messages.enterPassword}"
      user.echo = '*'
      user.badPassword = 0

    process: (user) ->
      if user.currentCmd.length > 0
        pw = user.currentCmd

        if bcrypt.compareSync(pw, user.foundUser.hash)
          user.name = user.foundUser.name
          user.changeState 'main'
        else
          user.badPassword++

          if user.badPassword >= 3
            user.write "\r\n#{user.mud.config.messages.invalidPasswordError}\r\n#{user.mud.config.messages.tooManyAttemptsError}"
            user.changeState 'goodbye'
          else
            user.write "\r\n#{user.mud.config.messages.invalidPasswordError}\r\n#{c[249]}#{user.mud.config.messages.enterPassword}"


      else
        user.write "\r\n#{user.mud.config.messages.enterPassword}"

  confirm:
    enter: (user) ->
      user.write "\r\n#{user.mud.config.messages.userCreatePrompt}"

    process: (user) ->
      if user.currentCmd.length > 0
        cmd = user.currentCmd[0].toUpperCase()

        if cmd is 'Y'
          user.name = user.confirmName
          user.changeState 'createpw'            
        else if cmd is 'N'
          user.write '\r\n'
          user.changeState 'login'
        else
          user.write "\r\n#{user.mud.config.messages.userCreatePromptError}\r\n#{userCreatePrompt}"

      else
        user.write "\r\n#{userCreatePrompt}"


  createpw:
    enter: (user) ->
      user.write "\r\n#{user.mud.config.messages.userCreatePasswordPrompt}"
      user.echo = '*'

    process: (user) ->
      if user.currentCmd.length > 0
        user.pass = user.currentCmd
        user.changeState 'confirmpw'
      else
        user.write "\r\n#{user.mud.config.messages.userCreatePasswordPrompt}"
 
  confirmpw: 
    enter: (user) ->
      user.write "\r\n#{user.mud.config.messages.userCreatePasswordReentry}"
      user.echo = '*'

    process: (user) ->
      if user.currentCmd.length > 0
        pw = user.currentCmd

        if pw is user.pass
          delete user.pass
          hash = bcrypt.hashSync(pw, 8)
          user.record = new user.mud.db.User name: user.name, hash: hash
          user.record.save ->
            user.changeState 'main'
        else
          user.write "\r\n#{user.mud.config.messages.userCreatePasswordMismatch}"
          user.changeState 'createpw'

      else
        user.write "\r\n#{user.mud.config.messages.userCreatePasswordReentry}"

  main:
    enter: (user) ->
      debugger
      user.write "\r\n#{user.mud.config.messages.mainUserEnterRealm}"
      user.mud.broadcast "#{user.mud.config.messages.mainUserEnterRealmBroadcast}", user
      user.echo = 'full'
      
    process: (user) ->
      if user.currentCmd.length > 0
        args = user.currentCmd.split ' '
        cmd = commands[args[0].toLowerCase()]
        user.commandArgs = args[1..]
        if cmd
          cmd user
        else
          user.write "\r\n#{user.mud.config.messages.mainInvalidCommand}\r\n>"       
        user.currentCmd = ''
        user.commandArgs = ''

      else
        user.write "\r\n>"

  goodbye:
    enter: (user) ->
      user.write "\r\n#{user.mud.config.messages.goodbye}\r\n"
      user.conn.end()
      user.echo = 'none'
    process: (user) ->
      # ignores input





