User = require './User'

users = []

module.exports = (conn) ->

  user = new User(conn)

  users.push user

  conn.on 'close', ->
    index = users.indexOf user
    users.splice index, 1