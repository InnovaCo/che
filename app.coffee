
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
coffee = require("coffee-script")
fs = require 'fs'

app = express()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get '/public/js/*.js', (req, res) ->

  res.header 'Content-Type', 'application/x-javascript'
  path = __dirname + "/app/client" + req.url.replace(/^\/public/js/, '').replace(".js", '')

  fs.exists path + ".coffee", (exists) ->
    if exists
      res.send coffee.compile fs.readFileSync path + ".coffee", "ascii"
    else
      res.send fs.readFileSync path + ".js", "ascii"
  

app.get "/", routes.index
app.get "/users", user.list
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")