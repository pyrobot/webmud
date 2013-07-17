colors = require './colors'

module.exports = class Parser

  constructor: (@expressionTarget) ->

  colorRegex: /\*{(.*?)}/
  parseColor: (str, strip) ->
    str = str or ""
    charArray = str.split('')

    while result = @colorRegex.exec str
      len = result[0].length
      index = str.indexOf result[0]

      try
        colorStr =  colors[result[1]]
      catch error
        colorStr = ''
        
      if strip then colorStr = ''
      charArray.splice result.index, len, colorStr
      str = charArray.join('')
      charArray = str.split('')

    return charArray.join('')

  parse: (str) -> @parseColor str

  strip: (str) -> @parseColor str, true