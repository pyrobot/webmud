module.exports = class Room

  constructor: (@roomManager, @roomId, @description, @exits) ->
    @entities = []

  addEntity: (entity) ->
    @entities.push entity

  removeEntity: (entity) ->
    index = @entities.indexOf entity
    @entities.splice index, 1

  broadcast: (msg, skipEntity...) ->
    for entity in @entities
      unless skipEntity.indexOf(entity) >= 0
        entity.displayMsg msg