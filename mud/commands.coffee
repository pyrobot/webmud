module.exports = commands =

  help: (user) ->
    user.write "\r\n    Available commands:\r\n"
    for key, val of commands
      user.write "\t#{key}\r\n"
    user.write ">"

  # say: (user) ->
  #   msg = user.strip user.commandArgs.join ' '
  #   user.write "\r\n*{82}You *{70}say: *{82}#{msg}*{249}\r\n>"
  #   user.mud.broadcast "*{82}#{user.name} *{70}says: *{82}#{msg}*{249}", user

  who: (user) ->
    allUsers = user.mud.users
    user.write "\r\nCurrently connected (*{255}#{allUsers.length}*{249})\r\n"
    for u, i in allUsers
      user.write "\t ##{i+1}: *{255}#{u.name}*{249}\r\n"
    user.write ">"

  # update: (user) ->
  #   user.update()
  #   user.write "\r\nUpdated!\r\n>"

  stat: (user) ->
    user.write "\r\nYou are a #{user.entity.type}.\r\n>"

  logoff: (user) ->
    user.changeState 'goodbye'
