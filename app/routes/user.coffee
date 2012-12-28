
#
# * GET users listing.
# 
module.exports = (app) ->
  app.get "/users", (req, res) ->
    res.send "respond with a resource"