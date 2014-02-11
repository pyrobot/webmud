module.exports =
  enter: ->
    @write "\r\n*{249}Re-enter the same *{255}password*{249}: "
    @echo = '*'

  process: ->
    if @currentCmd.length > 0
      pw = @currentCmd

      if pw is @pass
        @echo = 'full'
        @changeState 'createChar'
      else
        @write "\r\n*{196}Passwords do not match!"
        @changeState 'createpw'

    else
      @write "\r\n*{249}Re-enter the same *{255}password*{249}: "
