module.exports =
  enter: ->
    @writeln "*{226}You are being removed from the server.", "Reason: #{@forceQuitReason}" if @forceQuitReason
    @changeState 'goodbye'