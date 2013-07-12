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

  expressionRegex: /%{(.*?)}/
  parseExpression: (str, strip) ->
    str = str or ''
    charArray = str.split('')

    splitExpr = (expr) =>
      try
        obj = @expressionTarget
        for e in expr.split('.')
          obj = obj[e]
      catch err
        obj = ''

    while result = @expressionRegex.exec str
      len = result[0].length
      index = str.indexOf result[0]
      exprStr = splitExpr result[1]
      if strip then exprStr = ''
      charArray.splice result.index, len, exprStr
      str = charArray.join('')
      charArray = str.split('')

    return charArray.join('')

  parse: (str) -> @parseColor @parseExpression str

  strip: (str) -> @parseColor(@parseExpression(str, true), true)

