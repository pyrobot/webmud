module.exports = class Mud
  users: []

  addUser: (user) ->
    @users.push user
    console.log "User Connected.. Currently connected (#{@users.length})"
    user.conn.on 'close', =>
      index = @users.indexOf user
      @users.splice index, 1
      console.log "User Disconnected.. Currently connected (#{@users.length})"