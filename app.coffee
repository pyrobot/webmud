# coffeescript entry point
require 'coffee-trace' if process.env.NODE_ENV is not 'production'
require './mud/server.coffee'