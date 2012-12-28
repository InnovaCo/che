
#
# * GET home page.
# 
module.exports = (app) -> 
  app.get "/", (req, res) ->
    res.render "index",
      title: "Express"
