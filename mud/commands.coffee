c = require './colors'

module.exports = commands =

  help: (user, args) ->
    user.write "\r\n    Available commands:\r\n"
    for key, val of commands
      user.write "\t#{key}\r\n"
    user.write ">"

  say: (user, args) ->
    msg = args.join ' '
    user.write "\r\n#{c[82]}You #{c[70]}say: #{c[82]}#{msg}#{c[249]}\r\n>"
    user.mud.broadcast "#{c[82]}#{user.name} #{c[70]}says: #{c[82]}#{msg}#{c[249]}", user

  who: (user, args) ->
    allUsers = user.mud.users
    user.write "\r\nCurrently connected (#{c[255]}#{allUsers.length}#{c[249]})\r\n"
    for u, i in allUsers
      user.write "\t ##{i+1}: #{c[255]}#{u.name}#{c[249]}\r\n"
    user.write ">"

  logoff: (user, args) ->
    user.changeState 'goodbye'
