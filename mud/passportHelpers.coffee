users = [
  id: '1', username: 'admin', password: 'secret', name: 'Admin'
]

exports.find = (mud, id, done) ->
  for user in users
    if user.id is id then return done(null, user);
  return done null, null

exports.findByUsername = (mud, username, done) ->
  for user in users
    if user.username is username then return done null, user
  return done(null, null);
