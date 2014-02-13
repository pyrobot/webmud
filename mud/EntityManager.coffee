_ = require 'underscore'
Entity = require './Entity'

module.exports = class EntityManager

  constructor: (@mud) ->
    @entities = []
    @entityIdCtr = 0

  init: (@entityMasterList) ->

  add: (entityObject) ->
    @entityIdCtr++
    entity = new Entity(this, @entityIdCtr, entityObject?.name, entityObject?.type, entityObject?.gender, entityObject?.owner, entityObject?.controller)
    entity.room = @mud.roomManager.get entityObject.roomId
    entity.room.addEntity entity
    @entities.push entity
    return entity

  remove: (entityId) -> @removeEntity _.findWhere @entities, entityId: entityId

  removeEntity: (entityObject) ->
    # remove from current room
    entityObject?.room.removeEntity entityObject

    # remove from entity manager list
    index = @entities.indexOf entityObject
    @entities.splice index, 1

  updateTick: ->
    _.each @entities, (entity) ->
      # .. do update for entity