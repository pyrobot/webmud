# colors reference:
# https://raw.github.com/foize/go.sgr/master/xterm_color_chart.png

colors = {}

for i in [0..255]
  colors[i] = "\x1b[38;5;#{i}m"

module.exports = colors