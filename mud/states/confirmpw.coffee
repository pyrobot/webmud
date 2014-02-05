module.exports =
  enter: (user) ->
    user.write "\r\n*{249}Re-enter the same *{255}password*{249}: "
    user.echo = '*'

  process: (user) ->
    if user.currentCmd.length > 0
      pw = user.currentCmd

      if pw is user.pass
        user.echo = 'full'
        user.changeState 'createChar'
      else
        user.write "\r\n*{196}Passwords do not match!"
        user.changeState 'createpw'

    else
      user.write "\r\n*{249}Re-enter the same *{255}password*{249}: "
