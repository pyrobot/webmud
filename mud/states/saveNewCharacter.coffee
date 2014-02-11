bcrypt = require 'bcrypt'
_ = require 'underscore'

module.exports =
  enter: ->
      hash = bcrypt.hashSync @pass, 8

      @entity = 
        name: @name
        type: @race.name
        gender: '0'
        room: 0
        specialness: 0

      @record = new @mud.db.User
        name: @name
        hash: hash
        entity: @entity

      @record.save =>
        @changeState 'enterGame'