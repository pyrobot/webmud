module.exports =
  enter: (user) ->
    user.write "\r\n*{226}Goodbye!\r\n"
    user.conn.end()
    user.echo = 'none'