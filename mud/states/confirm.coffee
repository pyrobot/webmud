module.exports =
  enter: (user) ->
    user.write "\r\n*{249}User '*{255}#{user.confirmName}*{249}' does not exist, create? (*{34}Y*{249}/*{124}N*{249}) "

  process: (user) ->
    if user.currentCmd.length > 0
      cmd = user.currentCmd[0].toUpperCase()

      if cmd is 'Y'
        user.name = user.confirmName
        user.changeState 'createpw'            
      else if cmd is 'N'
        user.write '\r\n'
        user.changeState 'login'
      else
        user.write "\r\n*{249}Please enter *{34}Y*{249} or *{124}N*{249}.\r\n*{249}User '*{255}#{user.confirmName}*{249}' does not exist, create? (*{34}Y*{249}/*{124}N*{249}) "

    else
      user.write "\r\n*{249}User '*{255}#{user.confirmName}*{249}' does not exist, create? (*{34}Y*{249}/*{124}N*{249}) "
