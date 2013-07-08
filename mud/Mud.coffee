User = require './User'
states = require './states'

module.exports = class Mud
  users: []

  addUser: (conn) ->
    user = new User(conn, this, 'login')

    @users.push user

    user.conn.on 'close', =>
      index = @users.indexOf user
      @users.splice index, 1

  broadcast: (msg, skipUser) ->
    for user in @users
      unless user is skipUser or user.state isnt 'main'
        user.write "\r                                                                                                                              \r#{msg}\r\n>#{user.currentCmd}"

  states: states