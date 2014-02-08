module.exports =
  enter: (user) ->
    if currentLoggedInUser
      # copy the current logged in user data into this user
      user.record = currentLoggedInUser.record
      user.entity = currentLoggedInUser.entity
      user.name = currentLoggedInUser.name

      # force quit the other session
      currentLoggedInUser.forceQuit 'Logged in from different session.'

    user.write '\r\n>'
    user.changeState 'main'