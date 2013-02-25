define ['dom!', 'config', 'events', 'utils/params', "history"], (dom, config, events, params, history) ->
  return false if not history

  convertRequestData = (paramsString) ->
    list = paramsString.split ///,\s*///
    requestData = {}
    for lisItem in list
      splittedData = lisItem.split ///:\s*///
      requestData[splittedData[0]] = splittedData[1]

    return requestData


  dom('body').on "a[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
    data = @getAttribute config.reloadSectionsDataAttributeName
    url = @getAttribute 'href'

    events.trigger "pageTransition:init", [url, data, "GET"]
    e.preventDefault()
    return false
  events.bind "sectionsTransition:invoked, sectionsTransition:undone", ->
    events.trigger "pageTransition:stop"
    # sectionsRequest.complete (data) ->
    #   events.trigger "newSectionsLoaded", [data, requestData]