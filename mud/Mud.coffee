_ = require 'underscore'
fs = require 'fs'
Db = require './Db'
User = require './User'
states = require './states'
mongoose = require 'mongoose'
colors = require './colors'

EventEmitter = require('events').EventEmitter

EntityManager = require './EntityManager'
RoomManager = require './RoomManager'

child_process = require 'child_process'

# how often should users be saved
GLOBAL_UPDATE_TICKS = 30

# node hates coffee
timerJsFilePath = "#{__dirname}/timerShim.js"

module.exports = class Mud extends EventEmitter

  constructor: ->
    @db = new Db()
    @entityManager = new EntityManager(this)
    @roomManager = new RoomManager(this)
    @states = states
    @timerProcess = null
    @users = []

  getUserByName: (userName) -> _.findWhere @users, {name: userName, loggedIn: true}
  userLoggedIn: (userName) -> Boolean @getUserByName userName 
  
  addUser: (conn) ->
    user = new User(conn, this, 'connect')

    @users.push user
    console.log "New user connected (#{@users.length} total)"

    user.conn.on 'close', => @removeUser user

  removeUser: (user, updateFlag=true) ->
    index = @users.indexOf user
    if index >= 0
      user.update() if updateFlag
      @entityManager.removeEntity user.entity
      @users.splice index, 1
      console.log "User #{user.name || user.confirmName || ''} disconnected (#{@users.length} total)"
    else
      console.log "Session disconnected but user was already removed (#{user.name})"

  addEntity: (entityObject) -> @entityManager.add entityObject

  updateUsers: -> 
    _.chain(@users)
    .where(loggedIn: true)
    .each (user) -> user.update()

  broadcast: (msg, skipUser) ->
    for user in @users
      unless user is skipUser or user.state isnt 'main'
        # todo: change to use ANSI "clear until end of line" (instead of 57 spaces)
        user.write "\r#{new Array(57).join(' ')}\r#{msg}\r\n>#{user.currentCmd}"    

  start: (callback) ->
    console.log "Starting MUD"
    console.log "Connecting to database"

    @on 'initialized', => callback() if callback

    connectDb = (dbconfig) =>
      mongoose.connect(dbconfig.mongodb)
      mongoose.connection.once 'open', =>
        @db.defineSchemas(mongoose)
        query = @db.Config.findOne({})
        query.exec (err, foundConfig) =>
          if foundConfig
            @config = foundConfig
            @init()
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

  init: ->
    # Init room and entity managers
    @roomManager.init @config.rooms
    @entityManager.init @config.entities

    # Create timer process
    unless global.v8debug
      console.log "Creating timer process"
      @timerProcess = child_process.fork timerJsFilePath
      @timerProcess.on 'message', (tick) => @tickUpdate tick
      @timerProcess.on 'error', (err) -> console.log 'Error: ' + err.message
    else
      # having issues with child process not terminating in debug mode, so just use a setInterval and call tickUpdate manually
      console.log "Debug mode timer started"
      setInterval (=> @tickUpdate @currentTick+1), 1000
      process.nextTick => @tickUpdate 0

    console.log "Waiting for response from timer"
    @errorTimeout = setTimeout =>
      console.log "No response from timer, shutting down."
      process.exit(1)
    , 5000

  tickUpdate: (@currentTick) ->
    if @currentTick is 0
      clearTimeout @errorTimeout
      console.log "Timer message received"
      @emit 'initialized'
    else
      @entityManager.updateTick()
      @roomManager.updateTick()
      if (@currentTick % 10) is 0 then @updateUsers()
