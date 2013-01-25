fs = require 'fs'
path = require 'path'
coffee = require "coffee-script"

getJavascriptFile = (filePath, handler) ->
  fs.exists filePath + ".coffee", (exists) ->
    if exists
      handler coffee.compile fs.readFileSync filePath + ".coffee", "utf8"
    else
      fs.exists filePath + ".js", (exists) ->
        if exists
          handler fs.readFileSync filePath + ".js", "utf8"
        else
          handler null, 404

exports.coffee = (path, handler) ->
  return getJavascriptFile(path, handler)

