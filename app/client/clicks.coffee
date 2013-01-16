define ['dom', 'config', 'events', "lib/domReady", "ajax"], (dom, config, events, domReady, ajax) ->

  convertRequestData = (paramsString) ->
    list = paramsString.split ///,\s*///
    requestData = {}
    for lisItem in list
      splittedData = lisItem.split ///:\s*///
      if splittedData[0] isnt "pageView"
        requestData.widgets = requestData.widgets or {}
        requestData.widgets[splittedData[0]] = splittedData[1]
      else
        requestData[splittedData[0]] = splittedData[1]
    return requestData

  domReady ->
    dom('body').on "a[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
      data = @.getAttribute config.reloadSectionsDataAttributeName
      url = @.getAttribute 'href'
      events.trigger "pageTransition:init", [url, convertRequestData data]
      e.preventDefault()
      return false
    events.bind "sectionsTransition:invoked, sectionsTransition:undone", ->
      events.trigger "pageTransition:stop"

  sectionsRequest = null
  loadSections = (url, requestData) ->
    sectionsRequest?.abort()
    sectionsRequest = ajax.get
      url: url
      data: requestData

    # sectionsRequest.complete (data) ->
    #   events.trigger "newSectionsLoaded", [data, requestData]