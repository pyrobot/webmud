module.exports =
  enter: ->
    @write "\r\n*{249}User '*{255}#{@confirmName}*{249}' does not exist, create? (*{34}Y*{249}/*{124}N*{249}) "

  process: ->
    if @currentCmd.length > 0
      cmd = @currentCmd[0].toUpperCase()

      if cmd is 'Y'
        @name = @confirmName
        @changeState 'createpw'            
      else if cmd is 'N'
        @write '\r\n'
        @changeState 'login'
      else
        @write "\r\n*{249}Please enter *{34}Y*{249} or *{124}N*{249}.\r\n*{249}User '*{255}#{@confirmName}*{249}' does not exist, create? (*{34}Y*{249}/*{124}N*{249}) "

    else
      @write "\r\n*{249}User '*{255}#{@confirmName}*{249}' does not exist, create? (*{34}Y*{249}/*{124}N*{249}) "
