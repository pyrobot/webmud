http = require 'http'
express = require 'express'
coffeescript = require 'coffee-script'
path = require 'path'
fs = require 'fs'

app = express()

app.configure ->
  app.set 'port', process.env.PORT or 3000
  app.set 'views', "#{__dirname}/www/templates"
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.get '/', (req, res) ->
  res.render 'index'


readFile = (fileName) ->
  try
    console.log "Looking for #{path.join(__dirname, fileName)}"
    file = fs.readFileSync(path.join(__dirname, fileName), 'utf8')
  catch error
    console.log error
    file = null
  finally
    return file


app.get '/lib/:scriptName.js', (req, res) ->
  res.contentType 'application/javascript'
  file = readFile "www/lib/#{req.params.scriptName}.js"
  unless file is null then res.send(200, file) else res.send(404)


app.get '/scripts/:scriptName.js', (req, res) ->
  res.contentType 'application/javascript'
  file = readFile "www/scripts/#{req.params.scriptName}.coffee"
  unless file is null then res.send(200, coffeescript.compile file) else res.send(404)


app.use (req, res) ->
  res.redirect '/'


server = http.createServer app

port = app.get 'port'

server.listen port, -> console.log "Server started on port #{port}"