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

  # abort всех текущих запросов
  # во избежание их отложенной обработки после перехода на новый state
  events.bind "history:popState", (state) ->
    sectionsRequest?.abort()

  #### Интерфейс модуля: (url, method, sectionsHeader, index, data, sectionsParams) ->
  #
  # Кроме данных об пути, методе и необходимых секциях,
  # принимает параметр index, который добавляется к загруженным данным,
  # необходим для точного встраивания секций в цепь переходов, так как
  # могут быть запрошены данные для переходов в середине цепи
  #
  (url, method, sectionsHeader, index, data = [], sectionsParams) ->
    getState = (url, sections, params) ->
      try
        params = JSON.parse params

      url: url
      sectionsHeader: sectionsHeader
      sectionsParams: params
      index: index
      method: method
      sections: sections

    queryRequest = () ->
      sectionsContainer = dom(sectionsHeader)

      if dom(sectionsHeader)[0]?
        state = getState url, dom(sectionsHeader)[0].innerHTML, sectionsParams
        events.trigger "sections:loaded", state

    serverRequest = () ->
      sectionsRequest?.abort()
      sectionsRequest = ajax.dispatch
        url: url,
        method: method,
        data: data,
        headers:
          "X-Che": true
          "X-Che-Sections": sectionsHeader
          "X-Che-Params": sectionsParams
        type: "text"
        error: (request) ->
          state = getState url, sectionsHeader, sectionsParams
          events.trigger "sections:error", [state, request.status, request.statusText]

      sectionsRequest.success (request, sections) ->
        window.location.href = request.getResponseHeader "X-Che-Redirect" if request.getResponseHeader "X-Che-Redirect"
        state = getState (request.getResponseHeader "X-Che-Url"), sections, request.getResponseHeader "X-Che-Params"
        events.trigger "sections:loaded", state

    if _.isString(sectionsHeader) and sectionsHeader.indexOf(":") < 0 then queryRequest() else serverRequest()