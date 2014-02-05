_ = require 'underscore'
fs = require 'fs'
Db = require './Db'
User = require './User'
states = require './states'
mongoose = require 'mongoose'
colors = require './colors'

EntityManager = require './EntityManager'
Room = require './Room'

child_process = require 'child_process'

# node hates coffee
timerJsFilePath = "#{__dirname}/timerShim.js"

module.exports = class Mud

  # create new instances of the database, and entity manager
  db: new Db()
  em: new EntityManager()

  # attach the game states
  states: states

  # reference to timer child process gets created in the init function
  timerProcess: null

  # arrays holding the various mud objects
  rooms: []
  users: []

  addUser: (conn) ->
    user = new User(conn, this, 'connect')

    @users.push user
    console.log "New user connected (#{@users.length} total)"

    user.conn.on 'close', => @removeUser user

  removeUser: (user) ->
    index = @users.indexOf user
    @users.splice index, 1
    console.log "User #{user.name || user.confirmName || ''} disconnected (#{@users.length} total)"

  broadcast: (msg, skipUser) ->
    for user in @users
      unless user is skipUser or user.state isnt 'main'
        user.write "\r#{new Array(57).join(' ')}\r#{msg}\r\n>#{user.currentCmd}"    

  start: (callback) ->
    console.log "Starting MUD"
    console.log "Connecting to database"

    connectDb = (dbconfig) =>
      mongoose.connect(dbconfig.mongodb)
      mongoose.connection.once 'open', =>
        @db.defineSchemas(mongoose)
        query = @db.Config.findOne({})
        query.exec (err, foundConfig) =>
          if foundConfig
            @config = foundConfig
            @init(callback)
          else
            console.log "mudconfig not found"
            loadMudconfig()
      
    loadMudconfig = =>
      process.stdout.write 'Enter location to import mudconfig: '
      process.stdin.resume()
      process.stdin.setEncoding 'utf8'
      process.stdin.on 'data', (d) =>
        location = d.replace('\n', '')

        if fs.existsSync(location)
          @config = new @db.Config()
          mudconfig = JSON.parse(fs.readFileSync(location, 'utf8'))

          for key, val of mudconfig
            @config[key] = mudconfig[key]

          @config.save ->
            process.stdin.pause()
            process.stdin.removeAllListeners('data')
            callback()
        else
          process.stdout.write 'File not found.\nEnter location to import mudconfig: '

    location = './config/dbconfig.json'
    if fs.existsSync(location)
      dbconfig = JSON.parse(fs.readFileSync(location, 'utf8'))
      connectDb(dbconfig)
    else
      console.log 'dbconfig not found'

      process.stdout.write 'Enter mongodb connection string: '
      process.stdin.resume()
      process.stdin.setEncoding 'utf8'
      process.stdin.on 'data', (d) =>
        process.stdin.pause()
        process.stdin.removeAllListeners('data')
        dbconfig = mongodb: d.replace('\n', '')
        fs.writeFileSync location, JSON.stringify(dbconfig)
        connectDb(dbconfig)

  init: (callback) ->
    # TODO: convert to room manager
    for room in @config.rooms
      @rooms.push new Room(room.roomId, room.description, room.exits)

    # Init entity manager with entity list from config
    @em.init @config.entities

    # Create timer process in it's own thread
    @timerProcess = child_process.fork timerJsFilePath
    @timerProcess.on 'message', (tick) => @tickUpdate tick

    # Call the callback
    callback() if callback

  tickUpdate: (@currentTick) -> 
    @em.updateTick()
    # _.each @rooms, (r) -> r.updateTick()
