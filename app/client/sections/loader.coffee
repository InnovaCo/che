#### *module* sections/loader
#
# Загрузчик секций с сервера, данные о небходимых секциях
# отправляются в хидере "X-Che-Sections", это необходимо, чтобы
# точно отличать остальные запросы от запросов за секциями,
# так как согласно основной идее эти запросы отправляются всегда
# на разные url
#
define ["ajax", "events", "dom", "underscore"], (ajax, events, dom, _) ->
  sectionsRequest = null

  #### Интерфейс модуля: (url, method, sectionsHeader, index, data) ->
  #
  # Кроме данных об пути, методе и необходимых секциях,
  # принимает параметр index, который добавляется к загруженным данным,
  # необходим для точного встраивания секций в цепь переходов, так как
  # могут быть запрошены данные для переходов в середине цепи
  #
  (url, method, sectionsHeader, index, data = []) ->
    getState = (url, sections) ->
      url: url
      sectionsHeader: sectionsHeader
      index: index
      method: method
      sections: sections

    queryRequest = () ->
      sectionsContainer = dom(sectionsHeader)
      if dom(sectionsHeader)[0]?
        state = getState url, dom(sectionsHeader)[0].innerHTML
        events.trigger "sections:loaded", state

    serverRequest = () ->

      sectionsRequest?.abort()
      sectionsRequest = ajax.dispatch
        url: url,
        method: method,
        data: data,
        headers:
          "X-Che-Sections": sectionsHeader
          "X-Che": true
        type: "text"
        error: (request) ->
          state = getState url, sectionsHeader
          events.trigger "sections:error", [state, request.status, request.statusText]

      sectionsRequest.success (request, sections) ->
        window.location.href = request.getResponseHeader "X-Che-Redirect" if request.getResponseHeader "X-Che-Redirect"
        state = getState (request.getResponseHeader "X-Che-Url"), sections
        events.trigger "sections:loaded", state

    if _.isString(sectionsHeader) and sectionsHeader.indexOf(":") < 0 then queryRequest() else serverRequest()