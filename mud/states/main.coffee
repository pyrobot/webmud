commands = require '../commands'

module.exports =
  enter: (user) ->
    user.echo = 'full'
    user.write "\r\n*{249}Welcome, *{255}#{user.name}*{249}!\r\n*{255}#{user.name} has entered the realm.*{249}\r\n>"
    user.mud.broadcast "*{255}#{user.name} has entered the realm.*{249}", user
    user.createEntity()
    
  process: (user) ->
    if user.currentCmd.length > 0
      args = user.currentCmd.split ' '
      cmd = commands[args[0].toLowerCase()]
      user.commandArgs = args[1..]
      if cmd
        cmd user
      else
        user.write "\r\nInvalid command.. type '*{255}help*{249}' for help.\r\n>"       
      user.currentCmd = ''
      user.commandArgs = ''

    else
      user.write "\r\n>"
