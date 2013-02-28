#### *module* ajax
#
# Позволяет отправлять ajax-запросы на сервер
#


define ['events', 'utils/params', "utils/destroyer", "underscore"], (events, params, destroyer, _) ->

  createGETurl = (url, data) ->
    splittedUrl = url.split "?"
    getParams = if data? then "?#{params data}"  else if splittedUrl[1] then "?#{splittedUrl[1]}" else ""
    "#{splittedUrl[0]}#{getParams}"

  #### sendRequest(url, data, type, eventsSprout, headers)
  #
  # функция для отправки запроса на сервер
  #
  sendRequest = (url, data, type, method, eventsSprout, headers) ->
    request = createXMLHTTPObject()
    return false if not request 

    # request.responseType = type
    request.open method, url, true
    request.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
    request.setRequestHeader 'X-Che', 'true'
    if headers?
      for headerName, headerValue of headers
        request.setRequestHeader headerName, headerValue

    if data?
      data = params data
      request.setRequestHeader 'Content-type', 'application/x-www-form-urlencoded'


    # слушаем изменение состояния запроса
    # и отправляем различные события
    # — не должен выполняться, если был отменен
    request.onreadystatechange = ->
      return if request.readyState isnt 4 or request.status is 0

      if request.status isnt 200 and request.status isnt 304
        eventsSprout.trigger "error", [request, null]
        eventsSprout.trigger "complete", [request, null]
        return

      data = if request.responseText? then (parser[type] or parser.json) request.responseText else ""
      
      eventsSprout.trigger "success", [request, data]
      eventsSprout.trigger "complete", [request, data]

    if request.readyState is 4
      data = if request.responseText? then (parser[type] or parser.json) request.responseText else ""
      eventsSprout.trigger "complete", [request, data]
      return request

    eventsSprout.trigger "start", [request]
    request.send data
    request


  #### XMLHttpFactories
  #
  # массив фабрик XMLHttpRequest объекта
  #

  XMLHttpFactories = [
    -> return new XMLHttpRequest(),
    -> return new ActiveXObject("Msxml2.XMLHTTP"),
    -> return new ActiveXObject("Msxml3.XMLHTTP"),
    -> return new ActiveXObject("Microsoft.XMLHTTP")
  ]

  #### createXMLHTTPObject()
  #
  # создает объект XMLHttpRequest из подходящей фабрики, запоминает свое состояние
  #

  createXMLHTTPObject = ->
    xmlhttp = false
    for xmlhttpConstructor in XMLHttpFactories
      try
        xmlhttp = xmlhttpConstructor()
        createXMLHTTPObject = ->
          xmlhttpConstructor()
      catch e
       continue
      break
    xmlhttp

  #### parser
  #
  # Набор функций для парсинга responseText
  #

  parser = 
    json: (text) ->
      console.log text
      JSON.parse text
    text: (text) ->
      text
    default: (text) ->
      text


  defaultOptions =
    type: 'json',
    method: "GET"


  #### Ajax
  #
  # конструктор для ajax-объекта, создает объект, при возможности отправляет запрос и навешивает обработчиков событий
  #

  Ajax = (options) ->
    if options?
      @get options
    @

  Ajax:: =

    #### Ajax::get(options)
    #
    # отправляет запрос и навешивает обработчиков событий для конкретного запроса
    #
    get: (options) ->
      if @_events
        destroyer @_events

      if options.url?

        @_events = events.sprout()

        for eventName in ["start", "success", "error", "complete"]
          if _.isFunction options[eventName] then @_events.bind eventName, options[eventName], {},
            recall: true
            isSync: true

        @_request = sendRequest options.url,
          options.data or {},
          options.type or "",
          options.method or defaultOptions.method,
          @_events,
          options.headers
      @

    #### Ajax::abort(options)
    #
    # отменяет запрос
    #
    abort: ->
      @_request.abort()
      @

  #### Генерирование функций для Ajax::
  #
  # Ajax::success(handler), Ajax::error(handler), Ajax::complete(handler)
  # необходимы для подписки на события запроса
  #

  for eventName in ["start", "success", "error", "complete"]
    Ajax::[eventName] = (handler) ->
      @_events.bind eventName, handler,
        recall: true

  #### ajax(options)
  #
  # Интерфейс модуля
  #

  ajax = (options) ->
    new Ajax(options)

  #### ajax.get(options)
  #
  # Отправка GET-запросов
  #

  ajax.get = (options) ->
    options.method = "GET"
    if options.url?
      options.url = createGETurl options.url, options.data
    new Ajax(options)

  ajax

