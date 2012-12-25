define ['dom', 'config', 'events'], (dom, config, events) ->

  convertRequestData = (paramsString) ->
    list = paramsString.split ///,\s*///
    reqestData = {}
    for lisItem in list
      splittedData = lisItem.split ///:\s*///
      reqestData[splittedData[0]] = splittedData[1]
    return reqestData

  dom().on 'a[#{config.reloadSectionsDataAttributeName}]', "click", (e) ->
    data = @.getAttribute config.reloadSectionsDataAttributeName
    loadSections convertRequestData data
    return false

  sectionsRequest = null
  loadSections = (reqestData) ->
    if sectionsRequest?
      sectionsRequest.abort()
    else
      sectionsRequest = ajax config.sectionsRequestUrl
    sectionsRequest.get reqestData
    sectionsRequest.complete (data) ->
      events.trigger "newSectionsLoaded", [data, reqestData]
