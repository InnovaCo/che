define ["clicks/forms", "clicks/anchors", "history"], (forms, anchors, history) ->
  return false if not history

  handler = (url, data, method) ->
    events.trigger "pageTransition:init", [url, data, method]

  forms handler
  anchors handler

  events.bind "pageTransition:success", (data) ->
    events.trigger "pageTransition:stop", data
    # sectionsRequest.complete (data) ->
    #   events.trigger "newSectionsLoaded", [data, requestData]