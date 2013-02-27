define ["utils/storage"], (storage) ->

  helpers = 
    stateId: (url, header) ->
      return "#{url}|header:#{header}"


  save: (state) ->
    return false if _.isString(state.method) and state.method.toLowerCase() is "post"
    storage.save "sectionsHistory", helpers.stateId(state.url, state.header), state

  get: (url, header) ->
    storage.get "sectionsHistory", helpers.stateId(url, header)
