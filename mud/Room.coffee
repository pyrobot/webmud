module.exports = class Room

  constructor: (@roomId, @description, @exits) ->

  entities: []

  addEntity: (entity) ->
    @entities.push entity

  removeEntity: (entity) ->
    index = @entities.indexOf entity
    @entities.splice index, 1

  broadcast: (msg) ->
    for entity in entities
      entity.displayMsg msg
    