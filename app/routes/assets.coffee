assets = require "../helpers/assets"
path = require 'path'




exports.coffee = (req, res) ->
  res.header 'Content-Type', 'application/x-javascript'
  filePath = path.resolve(__dirname, "../client/" + req.params[0])
  console.log "path", req.params, filePath
  assets.coffee filePath, (file) ->
    if file 
      res.send file
    else
      res.send 404