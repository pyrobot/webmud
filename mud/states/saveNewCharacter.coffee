bcrypt = require 'bcrypt'
_ = require 'underscore'

module.exports =
  enter: (user) ->
      hash = bcrypt.hashSync(user.pass, 8)
      entity = 
        name: user.name
        type: user.race.name
        gender: '0'
        room: 0

      user.entity = _.extend {}, entity
      user.record = new user.mud.db.User name: user.name, hash: hash, entity: entity
      user.record.save ->
        user.changeState 'main'
