define ['dom', 'config', 'history', "lib/domReady", "ajax"], (dom, config, history, domReady, ajax) ->

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
    console.log history
    return false if not history
    historyIndex = 0
    dom('body').on "a[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
      data = @.getAttribute config.reloadSectionsDataAttributeName
      url = @.getAttribute 'href'
      console.log "request #{url}"
      loadSections(url, convertRequestData data).success (request, data) ->
        console.log "SUCCEESSS", data.url
        history.pushState {
            index: historyIndex++
            widgets: data.widgets
          }, data.title, data.url
      e.preventDefault()
      return false

  sectionsRequest = null
  loadSections = (url, requestData) ->
    console.log url, requestData
    sectionsRequest?.abort()
    sectionsRequest = ajax.get
      url: url
      data: requestData

    # sectionsRequest.complete (data) ->
    #   events.trigger "newSectionsLoaded", [data, requestData]