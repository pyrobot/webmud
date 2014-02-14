module.exports =
  enter: ->
    @writeln "*{249}Re-enter the same *{255}password*{249}: "
    @echo = '*'

  process: ->
    if @currentCmd.length > 0
      pw = @currentCmd

      if pw is @pass
        @echo = 'full'
        @changeState 'createChar'
      else
        @writeln "*{196}Passwords do not match!"
        @changeState 'createpw'

    else
      @writeln "*{249}Re-enter the same *{255}password*{249}: "
