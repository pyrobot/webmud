module.exports =
  enter: ->
    race = @selectedRace
    lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
    @write "\r\n#{@selectedRace.description}\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

  process: ->
    race = @selectedRace
    lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
    if @currentCmd.length > 0
      cmd = @currentCmd[0].toUpperCase()

      if cmd is 'Y'
        @race = @selectedRace
        @changeState 'saveNewCharacter'
      else if cmd is 'N'
        @changeState 'createChar'
      else
        @write "\r\nPlease enter a Y or N.\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

    else
      @write "\r\nYou have chosen '#{lname}', is this correct? (Y/N) "
