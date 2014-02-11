commands = require '../commands_global'

module.exports =
  enter: (user) ->
    user.echo = 'full'
    
  process: (user) ->
    if user.currentCmd.length > 0
      args = user.currentCmd.split ' '
      firstArg = args[0].toLowerCase()
      cmd = commands[firstArg] or user.entity.commands[firstArg]
      commandArgs = args[1..]
      if cmd
        cmd.apply user, commandArgs
      else
        user.write "\r\nInvalid command.. type '*{255}help*{249}' for help.\r\n>"       
      user.currentCmd = ''
      user.commandArgs = ''

    else
      user.write "\r\n>"
