commands = require './commands_entity'

module.exports = class Entity

  constructor: (@entityId, @name, @type, @gender, @controller=null, @roomId=null) ->
    @commands = commands

  displayMsg: (msg) -> @controller?.write msg if @controller

  updateTick: -> console.log 'Entity update'