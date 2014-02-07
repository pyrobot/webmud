_ = require 'underscore'
Room = require './Room'

module.exports = class RoomManager

  constructor: ->
  	@rooms = []

  init: (roomMaster) ->
    for room in roomMaster
      @rooms.push new Room(room.roomId, room.description, room.exits)

  updateTick: ->
    _.each @rooms, (room) ->
      # console.log "updating room #{room.roomId}"

  get: (id) -> _.findWhere @rooms, roomId: id