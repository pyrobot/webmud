module.exports =
  enter: (user) ->
    user.write "\r\n*{226}You are being removed from the server.\r\n"
    user.write "Reason: #{user.forceQuitReason}" if user.forceQuitReason
    user.changeState 'goodbye'