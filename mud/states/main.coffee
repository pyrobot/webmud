_ = require 'underscore'
commands = require '../commands_global'

# split on whitespace, and terms grouped in quotes (single or double)
cmdSplitRegex = /"([^\\"]*(?:\\.[^\\"]*)*)"|'([^\\']*(?:\\.[^\\']*)*)'|(\S+)/g

# used to check inner terms (to strip out quotes)
startsWithSingle = /^'/ 
endsWithSingle   = /'$/ 
startsWithDouble = /^"/ 
endsWithDouble   = /"$/ 

dequote = (str) ->
  # check if starts with single AND ends with single
  if startsWithSingle.test(str) and endsWithSingle.test(str) then return str.replace /(^')|('$)/g, ''
  # check if starts with double AND ends with double
  else if startsWithDouble.test(str) and endsWithDouble.test(str) then return str.replace /(^")|("$)/g, ''
  else return str

module.exports =
  enter: ->
    @echo = 'full'
    
  process: ->
    if @currentCmd.length > 0
      args = _.map(@currentCmd.match(cmdSplitRegex), dequote)
      firstArg = args[0].toLowerCase()
      cmd = commands[firstArg] or @entity.commands[firstArg]
      commandArgs = args[1..]
      if cmd
        cmd.apply this, commandArgs
      else
        @writelnp "Invalid command.. type '*{255}help*{249}' for help."
      @currentCmd = ''
      @commandArgs = ''

    else
      @writeln "#{@settings.prompt}"
