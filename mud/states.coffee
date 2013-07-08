commands = require './commands'
bcrypt = require 'bcrypt'

module.exports =

  login:
    enter: (user) ->
      user.write "
\r\n\x1b[31m\x1b[1m _       _         _             _   _  ___   
\r\n( )  _  ( )       ( )    /'\\_/`\\( ) ( )(  _`\\ 
\r\n| | ( ) | |   __  | |_   |     || | | || | ) |
\r\n| | | | | | /'__`\\| '_`\\ | (_) || | | || | | )
\r\n| (_/ \\_) |(  ___/| |_) )| | | || (_) || |_) |
\r\n`\\___x___/'`\\____)(_,__/'(_) (_)(_____)(____/'
\r\n-=-=-=-=-=============================%%***>>---                                                                                     
\r\n"
      user.write "Enter your username: "

    process: (user) ->
      if user.currentCmd.length > 0
        name = user.currentCmd.split(' ')[0]
        name = name[0...1].toUpperCase() + name[1..].toLowerCase()
        if name.length < 3 or name.length > 12
          user.write "\r\nName must be between 3 to 12 characters.\r\nEnter your name: "
        else unless (/^[a-zA-Z]+$/).exec(name)
          user.write "\r\nName contains invalid characters.\r\nEnter your username: "
        else
          query = user.mud.db.User.findOne({name: name})

          query.exec (err, foundUser) ->
            if foundUser
              user.foundUser = foundUser
              user.changeState 'password'
            else
              user.confirmName = name
              user.changeState 'confirm'

      else
        user.write "\r\nEnter your name: "

  password:
    enter: (user) ->
      user.write "\r\nEnter your Password: "
      user.echo = '*'
      user.badPassword = 0

    process: (user) ->
      if user.currentCmd.length > 0
        pw = user.currentCmd

        if bcrypt.compareSync(pw, user.foundUser.hash)
          user.name = user.foundUser.name
          user.changeState 'main'
        else
          user.badPassword++

          if user.badPassword >= 3
            user.write "\r\nInvalid password.\r\nToo many invalid password attempts."
            user.changeState 'goodbye'
          else
            user.write "\r\nInvalid password.\r\nEnter your Password: "


      else
        user.write "\r\nEnter your Password: "

  confirm:
    enter: (user) ->
      user.write "\r\nUser '#{user.confirmName}' does not exist, create? (Y/N) "

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
          user.write "\r\nPlease enter Y or N.\r\nUser '#{user.confirmName}' does not exist, create? (Y/N) "

      else
        user.write "\r\nUser '#{user.confirmName}' does not exist, create? (Y/N) "


  createpw:
    enter: (user) ->
      user.write "\r\nEnter a password: "
      user.echo = '*'

    process: (user) ->
      if user.currentCmd.length > 0
        user.pass = user.currentCmd
        user.changeState 'confirmpw'
      else
        user.write "\r\nEnter a password: "
 
  confirmpw: 
    enter: (user) ->
      user.write "\r\nRe-enter the same password: "
      user.echo = '*'

    process: (user) ->
      if user.currentCmd.length > 0
        pw = user.currentCmd

        if pw is user.pass
          delete user.pass
          hash = bcrypt.hashSync(pw, 8)
          user.record = new user.mud.db.User name: user.name, hash: hash
          user.record.save ->
            user.changeState 'main'
        else
          user.write "\r\nPasswords do not match!"
          user.changeState 'createpw'

      else
        user.write "\r\nRe-enter the same password: "

  main:
    enter: (user) ->
      user.write "\r\nWelcome, #{user.name}!\r\n"
      user.write "You have entered the realm.\r\n"
      user.mud.broadcast "#{user.name} has entered the realm.", user
      user.write ">"
      user.echo = 'full'
      
    process: (user) ->
      if user.currentCmd.length > 0
        args = user.currentCmd.split ' '
        user.currentCmd = ""
        cmd = commands[args[0].toLowerCase()]

        if cmd
          cmd user, args[1..]
        else
          user.write "\r\nInvalid command.. type 'help' for help.\r\n>"       

      else
        user.write "\r\n>"


  goodbye:
    enter: (user) ->
      user.write "\r\nGoodbye!\r\n"
      user.conn.end()
      user.echo = 'none'
    process: (user) ->
      # ignores input





