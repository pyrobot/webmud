module.exports =
  enter: (user) ->
    user.write "\r\n*{249}Enter a *{255}password*{249}: "
    user.echo = '*'

  process: (user) ->
    if user.currentCmd.length > 0
      user.pass = user.currentCmd
      user.changeState 'confirmpw'
    else
      user.write "\r\n*{249}Enter a *{255}password*{249}: "
