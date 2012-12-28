module.exports = (app) ->
  (require './main')(app)
  (require './che')(app)
  (require './javascripts')(app)