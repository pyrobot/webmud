module.exports = 
  enter: ->
    @writeln "*{249}Enter your *{255}username*{249}: "

  process: ->
    if @currentCmd.length > 0
      name = @currentCmd.split(' ')[0]
      name = name[0...1].toUpperCase() + name[1..].toLowerCase()
      if name.length < 3 or name.length > 12
        @writeln "Name must be between *{226}3*{249} to *{226}12*{249} characters.", "*{249}Enter your *{255}username*{249}: "
      else unless (/^[a-zA-Z]+$/).exec(name)
        @writeln "Name contains *{196}invalid characters*{249}.", "{249}Enter your *{255}username*{249}: "
      else
        query = @mud.db.User.findOne name: name

        query.exec (err, foundUser) =>
          if err
            return console.log "DB Err: " + err
          if foundUser
            @foundUser = foundUser
            @changeState 'checkLoggedIn'
          else
            @confirmName = name
            @changeState 'confirm'

    else
      @writeln "*{249}Enter your *{255}username*{249}: "