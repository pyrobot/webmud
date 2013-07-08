$ ->

  $window = $(window)

  sock = new SockJS('/ws')

  width = $window.width()
  height = $window.height()

  term = new Terminal(Math.floor(width / 7), Math.floor(height / 14))

  sock.onopen = ->
    term.write 'Connected to MUD server.\r\n'

  sock.onmessage = (e) ->
    term.write e.data

  sock.onclose = ->
    console.log 'Could not connect to server.\r\n'

  term.on 'data', (data) -> 
    sock.send data

  term.open()

  $window.on 'resize', (e) ->
    width = $window.width()
    height = $window.height()
    term.resize(Math.floor(width / 7), Math.floor(height / 14))