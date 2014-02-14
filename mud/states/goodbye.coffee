module.exports =
  enter: ->
    @writeln "*{226}Goodbye!\r\n"
    @mud.removeUser this
    @conn.end()
    @echo = 'none'