http = require 'http'
https = require 'https'
express = require 'express'
coffeescript = require 'coffee-script'
fs = require 'fs'
url = require 'url'
sockjs = require 'sockjs'
stylus = require 'stylus'
nib = require 'nib'
jade = require 'jade'

RedisStore = require('connect-redis')(express)

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
passportHelpers = require './passportHelpers'

Mud = require './Mud'
mud = new Mud()

app = express()

options =
  key: fs.readFileSync('./ssl/key.pem'),
  cert: fs.readFileSync('./ssl/cert.pem')

httpPort = 8080
httpsPort = 4343

isProduction = process.env.NODE_ENV is 'production'
isNodejitsu = isProduction and process.env.SUBDOMAIN

passport.use new LocalStrategy (username, password, done) ->
  passportHelpers.findByUsername mud, username, (err, user) ->
    if err then return done err
    if !user then return done null, false
    if user.password != password then return done null, false
    return done null, user

passport.serializeUser (user, done) -> done null, user.id
passport.deserializeUser (id, done) -> passportHelpers.find mud, id, (err, user) -> done err, user

# start up the mud
mud.start ->

  # configure the express server
  app.configure ->
    app.set 'port', process.env.PORT or httpsPort
    app.set 'views', "#{__dirname}/../www/templates"
    app.set 'view engine', 'jade'
    app.use express.favicon()
    app.use express.logger 'dev' unless isProduction
    app.use express.cookieParser()
    app.use express.bodyParser()
    app.use express.methodOverride()
    sessionObj = key: 'S', secret: 'roflcoptersaucelmaokeyboardcat'
    if isProduction and mud.settings.redis_store
      redisUrl = mud.settings.redis_store
      redis = url.parse redisUrl
      redisStore =
        host: redis.hostname
        port: redis.port
        pass: if redis.auth then redis.auth.substring(redis.auth.indexOf(':') + 1) else null
      sessionObj.store = new RedisStore(redisStore)
    app.use express.session sessionObj
    app.use passport.initialize()
    app.use passport.session()
    app.locals appTitle: "WebMUD"  

  # if running on nodejitsu, check if should redirect to https
  if isNodejitsu 
    app.use (req, res, next) ->
      if req.headers['x-forwarded-proto'] isnt 'https' then return res.redirect 301, "https://#{req.headers.host}/"
      next()
  else
    # start the http redirect server
    redirectServer = http.createServer (req, res) ->
      if req.headers['x-forwarded-proto'] isnt 'https'
        url = "https://#{req.headers.host.split(':')[0]}:#{httpsPort}/"
        res.writeHead 301, location: url
        return res.end "Redirecting to <a href='#{url}'>#{url}</a>."

    redirectServer.listen httpPort, -> console.log "HTTP redirect server started on port #{httpPort}"  

  # helper function to check if file exists (and then read it synchronously), and return its contents
  readFile = (fileName) ->
    file = null
    location = "#{__dirname}/#{fileName}"
    if fs.existsSync(location) then file = fs.readFileSync(location, 'utf8')
    return file

  # main route
  app.get '/', (req, res) -> res.render 'index'

  # serve the mudconfig
  app.get '/config', ensureLoggedIn('/'), (req, res) ->
    res.contentType 'application/json'
    file = readFile "../config/mudconfig.json"
    unless file is null then res.send(200, file) else res.send(404)

  # save the mudconfig
  app.post '/config', ensureLoggedIn('/'), (req, res) ->
    fs.writeFileSync "#{__dirname}/../config/mudconfig.json", JSON.stringify(req.body, undefined, 2)
    res.send 200

  # serve stats
  # app.get '/stats', ensureLoggedIn('/'), (req, res) -> res.json mud.stats()
  app.get '/stats', (req, res) -> res.json mud.stats()

  # route to serve javascript files (libraries)
  app.get '/lib/:scriptName.js', (req, res) ->
    res.contentType 'application/javascript'
    file = readFile "../www/lib/#{req.params.scriptName}.js"
    unless file is null then res.send(200, file) else res.send(404)

  # route to serve coffee-script files (app code)
  app.get '/scripts/:scriptName.js', (req, res) ->
    res.contentType 'application/javascript'
    file = readFile "../www/scripts/#{req.params.scriptName}.coffee"
    unless file is null then res.send(200, coffeescript.compile file) else res.send(404)

  # route to serve stylus/nib files as css
  app.get '/css/:styleName.css', (req, res) ->
    res.contentType 'text/css'
    file = readFile "../www/styl/#{req.params.styleName}.styl"
    unless file is null then res.send(200, stylus(file).use(nib()).render()) else res.send(404)

  # route to serve jade partials files as html
  app.get '/partials/:templateName.html', (req, res) ->
    res.contentType 'text/html'
    file = readFile "../www/partials/#{req.params.templateName}.jade"
    unless file is null then jade.render(file, (err, html) -> if err then res.send(404) else res.send(200, html)) else res.send(404)

  # final fallback route redirects back to main
  app.use (req, res) -> res.redirect '/'
  # get the admin route from mudsettings
  adminRoute = mud.settings.adminRoute

  # register admin route (for the client templates)
  app.locals.adminRoute = adminRoute

  # admin section route method=get 
  app.get "/#{adminRoute}", (req, res) -> res.render 'admin', user: req.user

  # post admin section route method=post (log in)
  app.post "/#{adminRoute}", passport.authenticate('local', { successReturnToOrRedirect: "/#{adminRoute}", failureRedirect: "/#{adminRoute}" })

  # admin section route method=delete (log out)
  app.delete "/#{adminRoute}", (req, res) ->
    req.logout()
    res.redirect "/#{adminRoute}"

  port = app.get 'port'

  # if app is running on nodejitsu
  if isNodejitsu
    # create standard http server (nodejitsu will forward proxy https and middleware will redirect)
    server = http.createServer app
  else
    # create the https server, local http server will handle redirects
    server = https.createServer options, app    

  # server error handler
  server.on 'error', (err) -> 
    switch err.message
      when 'listen EADDRINUSE' then console.log "Server cannot open port #{port} for listening, stopping."
      else console.log "There was an unhandled error with the express server: #{err.message}"      
    process.exit(1)

  # start the express server
  console.log "Starting web server."
  server.listen port, -> 
    console.log "MUD #{if !isNodejitsu then '(HTTPS) '}server started on port #{port}"

    # initialize websocket server (sockjs)
    websocketServer = sockjs.createServer()
    websocketServer.on 'connection', (conn) -> mud.addUser conn
    websocketServer.installHandlers server, prefix: '/ws'

    console.log "MUD startup complete"
