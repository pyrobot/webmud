$ ->
  term = new Terminal(80, 24)
  sock = new SockJS('/ws')

  sock.onopen = ->
    term.write 'Connected to MUD server.\r\n'

  sock.onmessage = (e) ->
    term.write e.data

  sock.onclose = ->
    console.log 'Lost connection.\r\n'

  term.on 'data', (data) -> 
    sock.send data

  term.open()