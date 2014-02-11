module.exports =
  enter: (user) ->
    user.write "\r\n*{226}Goodbye!\r\n"
    user.mud.removeUser user
    user.conn.end()
    user.echo = 'none'