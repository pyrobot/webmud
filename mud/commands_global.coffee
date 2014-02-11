module.exports = commands =

  help: ->
    @write "\r\n    Available commands:\r\n"
    for key, val of commands
      @write "\t#{key}\r\n"
    @write ">"

  who: ->
    allUsers = @mud.users
    @write "\r\nCurrently connected (*{255}#{allUsers.length}*{249})\r\n"
    for u, i in allUsers
      @write "\t ##{i+1}: *{255}#{u.name}*{249}\r\n"
    @write ">"

  stat: ->
    @write "\r\nYou are a #{@entity.type}.\r\n>"

  logoff: ->
    @changeState 'goodbye'

  special: ->
    @write "\r\nYou are special. (#{@record.entity.specialness++})\r\n>"
