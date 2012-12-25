
module.exports = (app) ->
  app.get '/sections', (req, res) ->
    res.send req.query