module.exports = (app) ->
  assets = require './assets'
  specs = require './specs'

  app.get '/spec/*.js', specs.assets
  app.get '/spec', specs.init
  app.get '/public/js/*.js', assets.coffee
  app.get '/jasmine.js', specs.jasmine
  app.get '/jasmine-helper.js', specs.jasmine_helper
  app.get '/jasmine-html.js', specs.jasmine_html
  app.get '/jasmine.css', specs.jasmine_css
  app.get '/:section', require './che'
  app.get '/', require './che'