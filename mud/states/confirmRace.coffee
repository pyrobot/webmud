module.exports =
  enter: ->
    race = @selectedRace
    lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
    @writeln "#{@selectedRace.description}", "You have chosen '#{lname}', is this correct? (Y/N) "

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
        @writeln "Please enter a Y or N.", "You have chosen '#{lname}', is this correct? (Y/N) "

    else
      @writeln "You have chosen '#{lname}', is this correct? (Y/N) "
