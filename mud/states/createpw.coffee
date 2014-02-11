module.exports =
  enter: ->
    @write "\r\n*{249}Enter a *{255}password*{249}: "
    @echo = '*'

  process: ->
    if @currentCmd.length > 0
      @pass = @currentCmd
      @changeState 'confirmpw'
    else
      @write "\r\n*{249}Enter a *{255}password*{249}: "
