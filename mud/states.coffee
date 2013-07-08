commands = require './commands'

module.exports =
  login:
    enter: (user) ->
      user.write "Enter your name: "

    process: (user) ->
      if user.currentCmd.length > 0
        name = user.currentCmd.split(' ')[0]
        name = name[0...1].toUpperCase() + name[1..].toLowerCase()
        if name.length > 16
          user.write "\r\nName must be shorter than 16 characters.\r\n>"
        else
          users = user.mud.users
          found = false
          for u in users
            if u.name is user.currentCmd
              found = true

          if found
            user.write "\r\nUser '#{user.currentCmd} already exists.\r\nEnter your name: "
          else
            user.confirmName = name
            user.changeState 'confirm'
      else
        user.write "\r\nEnter your name: "


  confirm:
    enter: (user) ->
      user.write "\r\nConfirm name is #{user.confirmName}? (Y/N) "

    process: (user) ->
      if user.currentCmd.length > 0
        cmd = user.currentCmd[0].toUpperCase()
        if cmd is 'Y'
          user.name = user.confirmName
          user.changeState 'main'            
        else if cmd is 'N'
          user.write '\r\n'
          user.changeState 'login'
        else
          user.write "\r\nConfirm name is #{user.confirmName}? (Y/N) "
      else
        user.write "\r\nConfirm name is #{user.confirmName}? (Y/N) "


  main:
    enter: (user) ->
      user.write "\r\nWelcome, #{user.name}!\r\n"
      user.write "You have entered the realm.\r\n"
      user.mud.broadcast "#{user.name} has entered the realm.", user
      user.write ">"
    process: (user) ->
      if user.currentCmd.length > 0
        args = user.currentCmd.split ' '
        user.currentCmd = ""
        cmd = commands[args[0]]
        if cmd
          cmd user, args[1..]
        else
          user.write "\r\nInvalid command.. type 'help' for help.\r\n>"       
      else
        user.write "\r\n>"