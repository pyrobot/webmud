http = require 'http'
express = require 'express'
coffeescript = require 'coffee-script'
fs = require 'fs'
sockjs = require 'sockjs'
stylus = require 'stylus'

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

app.get '/', (req, res) -> res.render 'index'

readFile = (fileName) ->
  file = null
  location = "#{__dirname}/#{fileName}"
  if fs.existsSync(location) then file = fs.readFileSync(location, 'utf8')
  return file

app.get '/lib/:scriptName.js', (req, res) ->
  res.contentType 'application/javascript'
  file = readFile "../www/lib/#{req.params.scriptName}.js"
  unless file is null then res.send(200, file) else res.send(404)

app.get '/scripts/:scriptName.js', (req, res) ->
  res.contentType 'application/javascript'
  file = readFile "../www/scripts/#{req.params.scriptName}.coffee"
  unless file is null then res.send(200, coffeescript.compile file) else res.send(404)

app.get '/css/:styleName.css', (req, res) ->
  res.contentType 'text/css'
  file = readFile "../www/styl/#{req.params.styleName}.styl"
  unless file is null then res.send(200, stylus(file).render()) else res.send(404)

# final fallback route redirects back to main
app.use (req, res) -> res.redirect '/'

server = http.createServer app

websocketServer = sockjs.createServer()

websocketServer.on 'connection', (conn) -> mud.addUser conn

websocketServer.installHandlers server, prefix: '/ws'

port = app.get 'port'

mud.start ->
  server.listen port, -> console.log "Server started on port #{port}"