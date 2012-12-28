define ['dom', 'config', 'events', "lib/domReady", "utils/ajax"], (dom, config, events, domReady, ajax) ->

  convertRequestData = (paramsString) ->
    list = paramsString.split ///,\s*///
    reqestData = {}
    for lisItem in list
      splittedData = lisItem.split ///:\s*///
      if splittedData[0] isnt "pageView"
        reqestData.widgets = reqestData.widgets or {}
        reqestData.widgets[splittedData[0]] = splittedData[1]
      else
        reqestData[splittedData[0]] = splittedData[1]
    return reqestData

  domReady ->
    dom('body').on "a[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
      data = @.getAttribute config.reloadSectionsDataAttributeName
      url = @.getAttribute 'href'
      loadSections url, convertRequestData data
      e.preventDefault()
      return false

  sectionsRequest = null
  loadSections = (url, reqestData) ->
    console.log url, reqestData
    sectionsRequest?.abort()
    sectionsRequest = ajax
      url: config.sectionsRequestUrl
      data: reqestData

    # sectionsRequest.complete (data) ->
    #   events.trigger "newSectionsLoaded", [data, reqestData]