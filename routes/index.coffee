module.exports = (app) ->
  (require './main')(app)
  (require './javascripts')(app)
  (require './reloadSections')(app)