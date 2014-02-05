module.exports = class Entity

  constructor: (@entityId, @name, @type, @gender, @roomId=null, @controller=null) ->

  displayMsg: (msg) -> @controller?.write msg if @controller

  updateTick: -> console.log 'Entity update'

  commands:
    look: ->
      room.look

    say: (msg) ->
      room.broadcast msg

