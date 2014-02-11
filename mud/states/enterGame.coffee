module.exports =
  enter: (user) ->
    # cant be sure that there weren't any changes to the user record while logging in, so refresh the latest saved record
    console.log "Name #{user.name}"
    query = user.mud.db.User.findOne name: user.name

    query.exec (err, foundUser) ->
      if err
        return console.log "DB Err: " + err

      if user.mud.userLoggedIn user.name
        return user.changeState 'checkLoggedIn'

      if foundUser
        user.loggedIn = true
        user.record = foundUser
        user.entity = user.record.entity
        user.write "\r\n*{249}Welcome, *{255}#{user.name}*{249}!\r\n*{255}#{user.name} has entered the realm.*{249}\r\n>"
        user.mud.broadcast "*{255}#{user.name} has entered the realm.*{249}", user
        user.createEntity()
        user.changeState 'main'
      else
        # should not get to this point, since the record should be in the database
        user.write "\r\n*{226}There was problem loading your data, please hit refresh."
        user.changeState 'goodbye'