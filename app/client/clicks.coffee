define ["clicks/forms", "clicks/anchors", "history", "events"], (forms, anchors, history, events) ->
  return false if not history

  handler = (url, data, method) ->
    events.trigger "pageTransition:init", [url, data, method]

  events.bind "pageTransition:success", (data) ->
    events.trigger "pageTransition:stop", data
    
  init = () ->
    forms handler
    anchors handler

  init.reset = ->
    forms.reset()
    anchors.reset()
    init()

  init()

  init