define ['events', 'utils/params', "utils/destroyer"], (events, params, destroyer) ->
  sendRequest = (url, data, type, eventsSprout) ->
    request = createXMLHTTPObject()
    return false if not request 

    request.responseType = type

    request.open method, url, true

    request.setRequestHeader 'User-Agent','XMLHTTP/1.0'

    if data?
      data = params data
      request.setRequestHeader 'Content-type','application/x-www-form-urlencoded'

    request.onreadystatechange = ->
      return if request.readyState isnt 4
      data = (parser[options.type] or parser.default) request.responseText
      console.log request
      if request.status isnt 200 and request.status isnt 304
        eventsSprout.trigger "error", [request, data]
      else
        eventsSprout.trigger "success", [request, data]
      eventsSprout.trigger "complete", [request, data]

    if request.readyState is 4
      eventsSprout.trigger "complete", [request]
      return request

    eventsSprout.trigger "start", [request]
    request.send data
    request

  XMLHttpFactories = [
    -> return new XMLHttpRequest(),
    -> return new ActiveXObject("Msxml2.XMLHTTP"),
    -> return new ActiveXObject("Msxml3.XMLHTTP"),
    -> return new ActiveXObject("Microsoft.XMLHTTP")
  ]

  createXMLHTTPObject = ->
    xmlhttp = false
    for xmlhttpConstructor in XMLHttpFactories
      try
        xmlhttp = xmlhttpConstructor()
      catch e
       continue
      break

    xmlhttp

  parser = 
    json: (text) ->
      JSON.parse text
    default: (text) ->
      text


  defaultOptions =
    type: 'json',
    method: "GET"


  Ajax = (options) ->
    if options?
      @get options

  Ajax:: =
    get: (options) ->
      if @_events
        destroyer @_events

      if options.url?

        @_events = events.sprout()

        for eventName in ["start", "success", "error", "complete"]
          options[eventName] ? @_events.bind eventName, options[eventName], 
            recall: true

        @_request = sendRequest options.url,
          options.data or {},
          options.type or "",
          options.method or defaultOptions.method
      @
      
    abort: ->
      @_request.abort()
      @

  for eventName in ["success", "error", "complete"]
    Ajax::[eventName] = (handler) ->
      @_events.bind eventName, handler,
        recall: true


  ajax = (options) ->
    new Ajax(options)

  ajax.get = (options) ->
    options.method = "GET"
    new Ajax(options)

