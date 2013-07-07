$ ->
  term = new Terminal(80, 24)
  sock = new SockJS('/echo')

  sock.onopen = -> term.write 'Connected to echo server.\r\n'
  sock.onmessage = (e) -> term.write e.data
  sock.onclose = -> console.log 'Lost connection.\r\n'

  term.on 'data', (data) -> sock.send data

  term.open()
