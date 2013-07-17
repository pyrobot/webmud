commands = require './commands'
bcrypt = require 'bcrypt'
_ = require 'underscore'

module.exports = states =
  connect:
    enter: (user) ->
      user.write "
\r\n*{40} _       _         _             _   _  ___
\r\n( )  _  ( )       ( )    /'\\_/`\\( ) ( )(  _`\\ 
\r\n| | ( ) | |   __  | |_   |     || | | || | ) |
\r\n| | | | | | /'__`\\| '_`\\ | (_) || | | || | | )
\r\n| (_/ \\_) |(  ___/| |_) )| | | || (_) || |_) |
\r\n`\\___x___/'`\\____)(_,__/'(_) (_)(_____)(____/'
\r\n*{240}-=-=-=-=-=============================*{253}%%*{239}****{160}>*{239}>*{249}---\r\n
"
      user.changeState 'login'

  login:
    enter: (user) ->
      user.write "*{249}Enter your *{255}username*{249}: "

    process: (user) ->
      if user.currentCmd.length > 0
        name = user.currentCmd.split(' ')[0]
        name = name[0...1].toUpperCase() + name[1..].toLowerCase()
        if name.length < 3 or name.length > 12
          user.write "\r\nName must be between *{226}3*{249} to *{226}12*{249} characters.\r\n*{249}Enter your *{255}username*{249}: "
        else unless (/^[a-zA-Z]+$/).exec(name)
          user.write "\r\nName contains *{196}invalid characters*{249}.\r\n*{249}Enter your *{255}username*{249}: "
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
        user.write "\r\n*{249}Enter your *{255}username*{249}: "

  password:
    enter: (user) ->
      user.write "\r\n*{249}Enter your *{255}password*{249}: "
      user.echo = '*'
      user.badPassword = 0

    process: (user) ->
      if user.currentCmd.length > 0
        pw = user.currentCmd

        if bcrypt.compareSync(pw, user.foundUser.hash)
          user.record = user.foundUser
          user.entity = user.record.entity
          user.name = user.record.name
          user.changeState 'main'
        else
          user.badPassword++
          
          if user.badPassword >= 3
            user.write "\r\n*{196}Invalid password.\r\n*{226}Too many invalid password attempts."
            user.changeState 'goodbye'
          else
            user.write "\r\n*{196}Invalid password.\r\n*{249}Enter your *{255}password*{249}: "

      else
        user.write "\r\n*{249}Enter your *{255}password*{249}: "

  confirm:
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


  createpw:
    enter: (user) ->
      user.write "\r\n*{249}Enter a *{255}password*{249}: "
      user.echo = '*'

    process: (user) ->
      if user.currentCmd.length > 0
        user.pass = user.currentCmd
        user.changeState 'confirmpw'
      else
        user.write "\r\n*{249}Enter a *{255}password*{249}: "
 
  confirmpw: 
    enter: (user) ->
      user.write "\r\n*{249}Re-enter the same *{255}password*{249}: "
      user.echo = '*'

    process: (user) ->
      if user.currentCmd.length > 0
        pw = user.currentCmd

        if pw is user.pass
          user.echo = 'full'
          user.changeState 'createChar'
        else
          user.write "\r\n*{196}Passwords do not match!"
          user.changeState 'createpw'

      else
        user.write "\r\n*{249}Re-enter the same *{255}password*{249}: "

  createChar:
    enter: (user) ->
        str = "\r\nChoose a race: ("
        for race in user.mud.config.races
          lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
          ex = (new RegExp(race.shortcut, 'i')).exec(lname)
          displayName = lname.slice(0, ex.index) + "*{255}#{ex[0]}*{249}" + lname.slice(ex.index+ex[0].length)
          str += displayName + ','
        str += "?) "
        user.write str

    process: (user) ->
      if user.currentCmd.length > 0 
        cmd = user.currentCmd.toLowerCase()
        found = _.find user.mud.config.races, (f) -> cmd is f.shortcut.toLowerCase() or cmd is f.name.toLowerCase()
        if found
          user.selectedRace = found
          user.changeState 'confirmRace'
        else
          str = "\r\nNot found!\r\nChoose a race: ("        
          for race in user.mud.config.races
            lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
            ex = (new RegExp(race.shortcut, 'i')).exec(lname)
            displayName = lname.slice(0, ex.index) + "*{255}#{ex[0]}*{249}" + lname.slice(ex.index+ex[0].length)
            str += displayName + ','
          str += "?) "
          user.write str

      else
        str = "\r\nChoose a race: ("        
        for race in user.mud.config.races
          lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
          ex = (new RegExp(race.shortcut, 'i')).exec(lname)
          displayName = lname.slice(0, ex.index) + "*{255}#{ex[0]}*{249}" + lname.slice(ex.index+ex[0].length)
          str += displayName + ','
        str += "?) "
        user.write str

  confirmRace:
    enter: (user) ->
      race = user.selectedRace
      lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
      user.write "\r\n#{user.selectedRace.description}\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

    process: (user) ->
      race = user.selectedRace
      lname =  "#{race.name[0...1].toUpperCase()}#{race.name[1..].toLowerCase()}"
      if user.currentCmd.length > 0
        cmd = user.currentCmd[0].toUpperCase()

        if cmd is 'Y'
          user.race = user.selectedRace
          user.changeState 'saveNewCharacter'
        else if cmd is 'N'
          user.changeState 'createChar'
        else
          user.write "\r\nPlease enter a Y or N.\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

      else
        user.write "\r\nYou have chosen '#{lname}', is this correct? (Y/N) "

  saveNewCharacter:
    enter: (user) ->
        hash = bcrypt.hashSync(user.pass, 8)
        entity = 
          name: user.name
          type: user.race.name
          gender: '0'
          room: 0

        user.entity = entity
        user.record = new user.mud.db.User name: user.name, hash: hash, entity: entity
        user.record.save ->
          user.changeState 'main'

  main:
    enter: (user) ->
      user.echo = 'full'
      user.write "\r\n*{249}Welcome, *{255}#{user.name}*{249}!\r\n*{255}#{user.name} has entered the realm.*{249}\r\n>"
      user.mud.broadcast "*{255}#{user.name} has entered the realm.*{249}", user
      
    process: (user) ->
      if user.currentCmd.length > 0
        args = user.currentCmd.split ' '
        cmd = commands[args[0].toLowerCase()]
        user.commandArgs = args[1..]
        if cmd
          cmd user
        else
          user.write "\r\nInvalid command.. type '*{255}help*{249}' for help.\r\n>"       
        user.currentCmd = ''
        user.commandArgs = ''

      else
        user.write "\r\n>"

  goodbye:
    enter: (user) ->
      user.write "\r\n*{226}Goodbye!\r\n"
      user.conn.end()
      user.echo = 'none'
    process: (user) ->
      # ignores input





