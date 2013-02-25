#### sections/loader
#
# Загрузка секций с сервера, обрабатывается только самый последний запрос
#

define ["ajax", "events"], (ajax, events) ->
  sectionsRequest = null
  (url, method, sectionsHeader, index) ->
    sectionsRequest?.abort()
    sectionsRequest = ajax.get
      url: url,
      method: method,
      headers:
        "X-Che-Sections": sectionsHeader
      type: "text"

    sectionsRequest.success (request, sections) ->
      state =
        url: request.getResponseHeader "X-Che-Url"
        header: sectionsHeader
        index: index
        method: method
        sections: sections

      events.trigger "sections:loaded", state