fs = require 'fs'
Db = require './Db'
User = require './User'
states = require './states'
mongoose = require 'mongoose'

module.exports = class Mud

  db: new Db()

  users: []

  addUser: (conn) ->
    user = new User(conn, this, 'login')

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
        user.write "\r                                                                                                                              \r#{msg}\r\n>#{user.currentCmd}"

  states: states

  start: (callback) ->
    console.log "Starting MUD"
    console.log "Connecting to database"

    connectDb = (dbconfig) =>
      mongoose.connect(dbconfig.mongodb)
      mongoose.connection.once 'open', =>
        @db.defineSchemas(mongoose)
        callback()

    location = 'dbconfig.json'

    if fs.existsSync(location)
      dbconfig = JSON.parse(fs.readFileSync(location, 'utf8'))
      connectDb(dbconfig)
    else
      console.log 'dbconfig not found'

      process.stdout.write 'Enter mongodb connection string: '
      process.stdin.resume()
      process.stdin.setEncoding 'utf8'
      process.stdin.on 'data', (d) =>
        dbconfig = mongodb: d.replace('\n', '')
        fs.writeFileSync location, JSON.stringify(dbconfig)
        connectDb(dbconfig)