
module.exports = (req, res) ->
    console.log "SECTION", req.params.section, console.log req.headers['x-requested-with']
    if req.headers['x-requested-with'] is 'xmlhttprequest'

      jade = require 'jade'

      data = {}
      params = require("url").parse(req.url, true).query

      for key, section of params
        selector = decodeURIComponent(key).match(///widgets\[(.*)\]///)[1]
        return false if not selector
        pathToTemplate = require('path').resolve(__dirname, '../views/sections/') + "/" + section + '.jade'
        template = require('fs').readFileSync(pathToTemplate, 'utf8')
        jadeFn = jade.compile(template, { filename: pathToTemplate, pretty: true })
        data[selector] = jadeFn({})
      res.json 
        url: req.url
        title: req.url
        widgets: data
    else
      try
        res.render req.params.section or "index",
          title: (req.params.section or "index") + " title"
      catch e
        console.log "another resource"