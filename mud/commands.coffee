module.exports = commands =

  help: (user) ->
    user.write "\r\n    Available commands:\r\n"
    for key, val of commands
      user.write "\t#{key}\r\n"
    user.write ">"

  say: (user) ->
    user.msg = user.strip user.commandArgs.join ' '
    user.write "\r\n#{user.mud.config.commands.sayMsgSelf}\r\n>"
    user.mud.broadcast "#{user.mud.config.commands.sayMsgBroadcast}", user

  who: (user) ->
    allUsers = user.mud.users
    user.write "\r\nCurrently connected (*{255}#{allUsers.length}*{249})\r\n"
    for u, i in allUsers
      user.write "\t ##{i+1}: *{255}#{u.name}*{249}\r\n"
    user.write ">"

  logoff: (user) ->
    user.changeState 'goodbye'
