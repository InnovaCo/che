define ['dom!', 'config', 'events', 'utils/params'], (dom, config, events, params) ->

  convertRequestData = (paramsString) ->
    list = paramsString.split ///,\s*///
    requestData = {}
    for lisItem in list
      splittedData = lisItem.split ///:\s*///
      if splittedData[0] isnt "pageView"
        requestData.widget = requestData.widget or {}
        requestData.widget[splittedData[0]] = splittedData[1]
      else
        requestData[splittedData[0]] = splittedData[1]

    return requestData

  dom('body').on "a[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
    data = convertRequestData @.getAttribute config.reloadSectionsDataAttributeName
    url = @.getAttribute 'href'

    splitted_url = url.split "?"

    events.trigger "pageTransition:init", ["#{splitted_url[0]}?#{if splitted_url[1] then splitted_url[1] + "&" else ""}#{params data}", "GET"]
    e.preventDefault()
    return false
  events.bind "sectionsTransition:invoked, sectionsTransition:undone", ->
    events.trigger "pageTransition:stop"
    # sectionsRequest.complete (data) ->
    #   events.trigger "newSectionsLoaded", [data, requestData]