module.exports =
  enter: ->
    @write "\r\n*{226}You are being removed from the server.\r\n"
    @write "Reason: #{@forceQuitReason}" if @forceQuitReason
    @changeState 'goodbye'