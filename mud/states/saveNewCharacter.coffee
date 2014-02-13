bcrypt = require 'bcrypt'
_ = require 'underscore'

module.exports =
  enter: ->
      hash = bcrypt.hashSync @pass, 8

      @entity = 
        name: @name
        type: @race.name
        gender: '0'
        roomId: 1
        specialness: 0

      @settings =
        prompt: '>'

      @record = new @mud.db.User
        name: @name
        hash: hash
        entity: @entity
        settings: @settings

      @record.save =>
        @changeState 'enterGame'