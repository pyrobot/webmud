commands = require './commands_entity'

module.exports = class Entity

  constructor: (@entityManager, @entityId, @name, @type, @gender, @owner=null, @controller=null) ->
    @commands = commands

  moveTo: (roomId) ->
    newRoom = @room.roomManager.get roomId
    @room.removeEntity this
    newRoom.addEntity this
    @room = newRoom

  displayMsg: (msg) -> 
    @controller?.write "\r#{new Array(57).join(' ')}\r#{msg}\r\n>#{@controller.currentCmd}" if @controller

  updateTick: -> console.log 'Entity update'