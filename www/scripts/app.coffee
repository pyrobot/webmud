$ ->

  $window = $(window)

  sock = new SockJS('/ws')

  width = $window.width()
  height = $window.height()

  term = new Terminal(Math.floor(width / 7), Math.floor(height / 14))

  sock.onmessage = (e) -> term.write(e.data)

  term.on 'data', (data) -> sock.send(data)

  term.open()

  $window.on 'resize', (e) ->
    width = $window.width()
    height = $window.height()
    term.resize(Math.floor(width / 7), Math.floor(height / 14))