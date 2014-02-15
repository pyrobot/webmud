http = require 'http'
express = require 'express'
coffeescript = require 'coffee-script'
fs = require 'fs'
sockjs = require 'sockjs'
stylus = require 'stylus'
nib = require 'nib'
jade = require 'jade'

Mud = require './Mud'
mud = new Mud()

app = express()

app.configure ->
  app.set 'port', process.env.PORT or 3000
  app.set 'views', "#{__dirname}/../www/templates"
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.locals appTitle: "WebMUD Revival!"

# helper function to check if file exists (and then read it synchronously), and return its contents
readFile = (fileName) ->
  file = null
  location = "#{__dirname}/#{fileName}"
  if fs.existsSync(location) then file = fs.readFileSync(location, 'utf8')
  return file

# main route
app.get '/', (req, res) -> res.render 'index'

# admin section route
app.get '/admin', (req, res) -> res.render 'admin'

# serve the mudconfig
app.get '/config', (req, res) ->
  res.contentType 'application/json'
  file = readFile "../config/mudconfig.json"
  unless file is null then res.send(200, file) else res.send(404)

# save the mudconfig
app.post '/config', (req, res) ->
  fs.writeFileSync "#{__dirname}/../config/mudconfig.json", JSON.stringify(req.body, undefined, 2)
  res.send 200

# serve stats
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

# create the http server
port = app.get 'port'
server = http.createServer app

# server error handler
server.on 'error', (err) -> 
  switch err.message
    when 'listen EADDRINUSE' then console.log "Server cannot open port #{port} for listening, stopping."
    else console.log "There was an unhandled error with the express server: #{err.message}"      
  process.exit(1)

# start the express server
console.log "Starting web server."
server.listen port, -> 
  console.log "Server started on port #{port}"

  # initialize websocket server (sockjs)
  websocketServer = sockjs.createServer()
  websocketServer.on 'connection', (conn) -> mud.addUser conn
  websocketServer.installHandlers server, prefix: '/ws'

  # finally, start the mud
  mud.start -> console.log "Mud server startup complete."
  