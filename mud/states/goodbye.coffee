module.exports =
  enter: ->
    @write "\r\n*{226}Goodbye!\r\n"
    @mud.removeUser this
    @conn.end()
    @echo = 'none'