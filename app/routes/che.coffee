
module.exports = (req, res) ->
    console.log("GET")
    if req.headers['x-che'] is 'true'
      jade = require 'jade'

      data = []
      params = require("url").parse(req.url, true).query

      for key, section of params
        console.log key
        selector = decodeURIComponent(key).match(///widgets\[(.*)\]///)[1]
        return false if not selector
        pathToTemplate = require('path').resolve(__dirname, '../views/sections/') + "/" + section + '.jade'
        template = require('fs').readFileSync(pathToTemplate, 'utf8')
        jadeFn = jade.compile(template, { filename: pathToTemplate, pretty: true })
        data.push "<section data-selector='#{selector}'>#{jadeFn({})}</section>"

      res.header 'x-che-url', req.url
      res.send data.join ''
    else
      try
        res.render req.params.section or "index",
          title: (req.params.section or "index") + " title"
      catch e
        req.next()