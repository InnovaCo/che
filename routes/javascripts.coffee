coffee = require "coffee-script"
fs = require 'fs'


module.exports = (app) ->
  app.get '/public/js/*.js', (req, res) ->
    res.header 'Content-Type', 'application/x-javascript'
    path = "./app/client" + req.url.replace(///^/public/js///, '').replace(".js", '').split("?")[0]

    fs.exists path + ".coffee", (exists) ->
      if exists
        res.send coffee.compile fs.readFileSync path + ".coffee", "ascii"
      else
        res.send fs.readFileSync path + ".js", "ascii"