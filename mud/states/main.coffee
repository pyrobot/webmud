commands = require '../commands_global'

module.exports =
  enter: ->
    @echo = 'full'
    
  process: ->
    if @currentCmd.length > 0
      args = @currentCmd.split ' '
      firstArg = args[0].toLowerCase()
      cmd = commands[firstArg] or @entity.commands[firstArg]
      commandArgs = args[1..]
      if cmd
        cmd.apply this, commandArgs
      else
        @write "\r\nInvalid command.. type '*{255}help*{249}' for help.\r\n>"       
      @currentCmd = ''
      @commandArgs = ''

    else
      @write "\r\n>"
