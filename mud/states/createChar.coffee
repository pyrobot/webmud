_ = require 'underscore'

module.exports =
  enter: (user) ->
      str = "\r\nChoose a race: ("
      for race in user.mud.config.races
        lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
        ex = (new RegExp(race.shortcut, 'i')).exec(lname)
        displayName = lname.slice(0, ex.index) + "*{255}#{ex[0]}*{249}" + lname.slice(ex.index+ex[0].length)
        str += displayName + ','
      str += "?) "
      user.write str

  process: (user) ->
    if user.currentCmd.length > 0 
      cmd = user.currentCmd.toLowerCase()
      found = _.find user.mud.config.races, (f) -> cmd is f.shortcut.toLowerCase() or cmd is f.name.toLowerCase()
      if found
        user.selectedRace = found
        user.changeState 'confirmRace'
      else
        str = "\r\nNot found!\r\nChoose a race: ("        
        for race in user.mud.config.races
          lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
          ex = (new RegExp(race.shortcut, 'i')).exec(lname)
          displayName = lname.slice(0, ex.index) + "*{255}#{ex[0]}*{249}" + lname.slice(ex.index+ex[0].length)
          str += displayName + ','
        str += "?) "
        user.write str

    else
      str = "\r\nChoose a race: ("        
      for race in user.mud.config.races
        lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
        ex = (new RegExp(race.shortcut, 'i')).exec(lname)
        displayName = lname.slice(0, ex.index) + "*{255}#{ex[0]}*{249}" + lname.slice(ex.index+ex[0].length)
        str += displayName + ','
      str += "?) "
      user.write str
