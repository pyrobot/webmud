bcrypt = require 'bcrypt'
_ = require 'underscore'

module.exports =
  enter: (user) ->
      hash = bcrypt.hashSync(user.pass, 8)
      user.entity = 
        name: user.name
        type: user.race.name
        gender: '0'
        room: 0
      user.record = new user.mud.db.User name: user.name, hash: hash, entity: user.entity
      user.record.save ->
        user.changeState 'main'