module.exports = 
  enter: (user) ->
    user.write "*{249}Enter your *{255}username*{249}: "

  process: (user) ->
    if user.currentCmd.length > 0
      name = user.currentCmd.split(' ')[0]
      name = name[0...1].toUpperCase() + name[1..].toLowerCase()
      if name.length < 3 or name.length > 12
        user.write "\r\nName must be between *{226}3*{249} to *{226}12*{249} characters.\r\n*{249}Enter your *{255}username*{249}: "
      else unless (/^[a-zA-Z]+$/).exec(name)
        user.write "\r\nName contains *{196}invalid characters*{249}.\r\n*{249}Enter your *{255}username*{249}: "
      else
        query = user.mud.db.User.findOne name: name

        query.exec (err, foundUser) ->
          if err
            return console.log "DB Err: " + err
          if foundUser
            user.foundUser = foundUser
            user.changeState 'checkLoggedIn'
          else
            user.confirmName = name
            user.changeState 'confirm'

    else
      user.write "\r\n*{249}Enter your *{255}username*{249}: "