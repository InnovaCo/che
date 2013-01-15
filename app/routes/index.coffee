module.exports = (app) ->
  app.get '/:section', require './che'
  app.get '/', require './che'
  app.get '/public/js/*.js', require './javascripts'