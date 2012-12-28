
module.exports = (app) ->
  app.get '/:section', (req, res) ->
    if req.headers['x-requested-with'] is 'XMLHttpRequest'

      jade = require 'jade'

      data = {}
      params = require("url").parse(req.url, true).query
      for selector, section of params
        pathToTemplate = require('path').resolve(__dirname, '../views/sections/') + "/" + section + '.jade'
        template = require('fs').readFileSync(pathToTemplate, 'utf8')
        jadeFn = jade.compile(template, { filename: pathToTemplate, pretty: true })
        data[selector] = jadeFn({})
      res.json data
    else
      res.render req.params.section or "index",
        title: (req.params.section or "index") + " title"