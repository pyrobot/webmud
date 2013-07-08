module.exports = commands =

  help: (user, args) ->
    user.write "\r\n    Available commands:\r\n"
    for key, val of commands
      user.write "\t#{key}\r\n"
    user.write ">"

  say: (user, args) ->
    msg = args.join ' '
    user.write "\r\nYou say: '#{msg}'\r\n>"
    user.mud.broadcast "#{user.name} says: '#{msg}'", user

  who: (user, args) ->
    allUsers = user.mud.users
    user.write "\r\nCurrently connected (#{allUsers.length})\r\n"
    for u, i in allUsers
      user.write "\t ##{i+1}: #{u.name}\r\n"
    user.write ">"

  logoff: (user, args) ->
    user.changeState 'goodbye'
