module.exports =
  enter: (user) ->
    race = user.selectedRace
    lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
    user.write "\r\n#{user.selectedRace.description}\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

  process: (user) ->
    race = user.selectedRace
    lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
    if user.currentCmd.length > 0
      cmd = user.currentCmd[0].toUpperCase()

      if cmd is 'Y'
        user.race = user.selectedRace
        user.changeState 'saveNewCharacter'
      else if cmd is 'N'
        user.changeState 'createChar'
      else
        user.write "\r\nPlease enter a Y or N.\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

    else
      user.write "\r\nYou have chosen '#{lname}', is this correct? (Y/N) "
