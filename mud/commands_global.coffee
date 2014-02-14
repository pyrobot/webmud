module.exports = commands =

  help: ->
    @writeln "    Available commands:"
    for key, val of commands
      @writeln "\t#{key}"
    @writeln "#{@settings.prompt}"

  who: ->
    allUsers = @mud.users
    @writeln "Currently connected (*{255}#{allUsers.length}*{249})"
    for u, i in allUsers
      @writeln "\t ##{i+1}: *{255}#{u.name}*{249}"
    @writeln "#{@settings.prompt}"

  stat: ->
    @writelnp "You are a #{@entity.type}."

  logoff: ->
    @changeState 'goodbye'

  special: ->
    @writelnp "You are special. (#{@record.entity.specialness++})"

  set: (key, val) ->
    unless key and val then return @writelnp "Invalid command.", "Syntax: set <property> <value>"
    @set key, val