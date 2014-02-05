_ = require 'underscore'
Entity = require './Entity'

module.exports = class EntityManager

  entities: []
  entityIdCtr: 0

  init: (@entityMaster) ->

  add: (entityObject) ->
    @entityIdCtr++
    entity = new Entity(@entityIdCtr, entityObject?.name, entityObject?.type, entityObject?.gender)
    @entities.push entity
    return entity

  remove: (entityId) -> @removeEntity _.findWhere @entities, entityId: entityId

  removeEntity: (entityObject) ->
    index = @entities.indexOf entityObject
    @entities.splice index, 1

  updateTick: ->
    _.each @entities, (entity) ->
      # .. do update for entity