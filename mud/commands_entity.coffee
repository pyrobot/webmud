_ = require 'underscore'

obviousExits = ['north', 'northeast', 'east', 'southeast', 'south', 'southwest', 'west', 'northwest', 'up', 'down']

opposites =
  north: 'south'
  northeast: 'southwest'
  east: 'west'
  southeast: 'northwest'
  south: 'north'
  southwest: 'northeast'
  west: 'east'
  northwest: 'southeast'  

module.exports = commands =
  spawn: (target) ->
    unless target then return @write "\r\nSpawn a what?\r\n>"
    @mud.entityManager.add
      name: target
      type: 'none'
      gender: '0'
      roomId: 1
      specialness: 0

    @write "\r\nYou spawn '#{target}'\r\n>"
    @entity.room.broadcast "#{target} has appeared!", @entity

  l: (target) -> commands.look.apply this, arguments
  look: (target) ->
    room = @entity.room
    if target
      t = target.toLowerCase()
      
      matches = _.filter room.entities, (e) -> 
        re = new RegExp "\\b#{t}", "g"
        re.test e.name.toLowerCase()

      if matches.length > 0
        lookAt = _.findWhere matches, (e) -> e.name.toLowerCase() is t
        if matches.length is 1 then lookAt = matches[0]
        if lookAt
          if lookAt is @entity
            @write "\r\nYou look at yourself.\r\n>"
            room.broadcast "#{@entity.name} looks at themselves.", @entity
          else
            @write "\r\nYou look at #{lookAt.name}.\r\n>"
            lookAt.displayMsg "#{@entity.name} looks at you."
            room.broadcast "#{@entity.name} looks at #{lookAt.name}", @entity, lookAt
        else
          @write "\r\nMatches: #{_.pluck(matches,'name')}\r\n>"
      else
        @write "\r\n'#{target}' cannot be found.\r\n>"

    else
      @write "\r\n#{room.description}"
      entities = _.filter room.entities, (e) => e isnt @entity
      if entities.length > 0
        entityNames = _.pluck entities, 'name'
        @write "\r\nIn the room: #{entityNames.join(', ')}"

      exits = _.filter room.exits, (e) => obviousExits.indexOf(e.type) >= 0
      if exits.length > 0
        exitTypes = _.pluck exits, 'type'
        @write "\r\nObvious exits: #{exitTypes}"

      @write "\r\n>"

  go: (target) ->
    unless target then return @write "\r\nGo where?\r\n>"

    exits = @entity.room.exits
    t = target.toLowerCase()

    exit = _.findWhere exits, type: t
    if exit
      if obviousExits.indexOf(t) <= 8 
        enterMsg = "#{@entity.name} leaves to the #{target}."
        exitMsg = "#{@entity.name} enters from the #{opposites[target]}."
      if t is 'up'
        enterMsg = "#{@entity.name} leaves upwards"
        exitMsg = "#{@entity.name} enters from below."
      if t is 'down'
        enterMsg = "#{@entity.name} leaves downwards."
        exitMsg = "#{@entity.name} enters from above."

      @entity.room.broadcast enterMsg, @entity
      @entity.moveTo exit.to
      @entity.room.broadcast exitMsg, @entity
      commands.look.call this
    else
      if obviousExits.indexOf(t) >= 0
        @write "\r\nThere is no exit in that direction.\r\n>"
      else
        @write "\r\nYou cannot go there.\r\n>"

  # movement aliases
  n: -> commands.go.call this, 'north'
  north: -> commands.go.call this, 'north'

  ne: -> commands.go.call this, 'northeast'
  northeast: -> commands.go.call this, 'northeast'

  e: -> commands.go.call this, 'east'
  east: -> commands.go.call this, 'east'

  se: -> commands.go.call this, 'southeast'
  southeast: -> commands.go.call this, 'southeast'

  s: -> commands.go.call this, 'south'
  south: -> commands.go.call this, 'south'

  sw: -> commands.go.call this, 'southwest'
  southwest: -> commands.go.call this, 'southwest'

  w: -> commands.go.call this, 'west'
  west: -> commands.go.call this, 'west'

  nw: -> commands.go.call this, 'northwest'
  northwest: -> commands.go.call this, 'northwest'

  u: -> commands.go.call this, 'up'
  up: -> commands.go.call this, 'up'

  d: -> commands.go.call this, 'down'
  down: -> commands.go.call this, 'down'

  say: ->
    msg = @currentCmd.slice 4
    @write "\r\nYou say: #{msg}\r\n>"
    @entity.room.broadcast "#{@entity.name} says: #{msg}", @entity

