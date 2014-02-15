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
        user.write "\r#{new Array(57).join(' ')}\r#{msg}\r\n#{user.settings.prompt}#{user.currentCmd}"    

  start: (callback) ->
    console.log "Starting MUD"

    @on 'initialized', => callback() if callback

    connectDb = (mudsettings) =>
      @settings = mudsettings
      mongodb_connect = if process.env.NODE_ENV is 'production' then @settings.mongodb_prod else @settings.mongodb_dev 
      console.log "Connecting to #{if process.env.NODE_ENV is 'production' then 'PROD' else 'DEV'} database: #{mongodb_connect}"
      mongoose.connect mongodb_connect
      mongoose.connection.once 'open', =>
        @db.defineSchemas(mongoose)
        query = @db.Config.findOne {}
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

    location = './config/mudsettings.json'
    if fs.existsSync(location)
      mudsettings = JSON.parse(fs.readFileSync(location, 'utf8'))
      connectDb(mudsettings)
    else
      console.log 'mudsettings not found, creating:'
      mudsettings = {}

      # todo - fix the waterfall
      process.stdout.write 'Enter admin route (admin) '
      process.stdin.resume()
      process.stdin.setEncoding 'utf8'
      process.stdin.on 'data', (d) =>
        process.stdin.pause()
        process.stdin.removeAllListeners('data')
        mudsettings.adminRoute = d.replace('\n', '')
        process.stdout.write 'Enter dev mongodb connection string: '
        process.stdin.resume()
        process.stdin.setEncoding 'utf8'
        process.stdin.on 'data', (d) =>
          process.stdin.pause()
          process.stdin.removeAllListeners('data')
          mudsettings.mongodb_dev = d.replace('\n', '')
          process.stdout.write 'Enter prod mongodb connection string: '
          process.stdin.resume()
          process.stdin.setEncoding 'utf8'
          process.stdin.on 'data', (d) =>
            process.stdin.pause()
            process.stdin.removeAllListeners('data')
            mudsettings.mongodb_prod = d.replace('\n', '')
            fs.writeFileSync location, JSON.stringify(mudsettings)
            connectDb(mudsettings)

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

  stats: ->
    users: _.map @users, (u) -> 
      connection:
        id: u.conn.id
        'user-agent': u.conn['user-agent']
        host: u.conn.host
        remoteAddress: u.conn.remoteAddress
      loggedIn: u.loggedIn
      name: u.name
      entity:
        name: u?.entity?.name
        type: u?.entity?.type
        roomId: u?.entity?.room.roomId
    currentTick: @currentTick
