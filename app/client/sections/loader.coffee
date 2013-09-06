#### *module* sections/loader
#
# Загрузчик секций с сервера, данные о небходимых секциях
# отправляются в хидере "X-Che-Sections", это необходимо, чтобы
# точно отличать остальные запросы от запросов за секциями,
# так как согласно основной идее эти запросы отправляются всегда
# на разные url
#
define [
  "ajax",
  "events",
  "dom",
  "underscore",
  "history",
  "config",
  "utils/params"
], (ajax, events, dom, _, history, config, params) ->
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
    sectionsLoader = arguments.callee

    getState = (url, sections, params) ->
      try
        params = JSON.parse params

      new history.CheState
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
        # Если был получен редирект то пытаемся его сделать с помощью che составив
        # правильный sectionsHeader
        if typeof(request.getResponseHeader) == "function"
          if request.getResponseHeader "X-Che-Redirect"
            redirectSections = []
            paramsList = params (request.getResponseHeader "X-Che-Redirect"), true
            defaultSection = getRedirectSections config.redirectDefaultRuleName, config.redirectRules[config.redirectDefaultRuleName]
            redirectSections.push defaultSection if defaultSection?

            for field, value of paramsList
              sectionsTemplate = config.redirectRules[field]

              if sectionsTemplate
                redirectSections.push getRedirectSections value, sectionsTemplate

            sectionsLoader (request.getResponseHeader "X-Che-Redirect"), method, redirectSections.join(";"), index, data, sectionsParams
          else
            state = getState (request.getResponseHeader "X-Che-Url"), sections, request.getResponseHeader "X-Che-Params"
            events.trigger "sections:loaded", state

    getRedirectSections = (value, params) ->
      sections = []

      # Проверяем масив ли у нас в параметрах и в зависимости от этого по разному
      # собираем sectionsHeader
      if params?
        if _.isArray params
          for param in params
            sections.push "#{param.sectionName}: " + JSON.stringify(param.params)
        else
          sections.push "#{value}: " + JSON.stringify(params)
        sections.join ";"

    if _.isString(sectionsHeader) and sectionsHeader.indexOf(":") < 0 then queryRequest() else serverRequest()