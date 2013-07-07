http = require 'http'
express = require 'express'

app = express()

app.configure ->
  app.set 'port', process.env.PORT or 3000
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.get '/', (req, res) ->
  res.end 'Hello Express'

app.use (req, res) ->
  res.redirect '/'

server = http.createServer app

port = app.get 'port'

server.listen port, -> console.log "Server started on port #{port}"