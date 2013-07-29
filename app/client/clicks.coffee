#### *module* clicks
#
# Используя модули из clicks/, навешивает обработчиков
# на клики по сабмиту форм и ссылкам, принимает данные
# и запускает механизм перехода между страниц, также
# проверяет наличие history, при его отсутствии прекращает
# дальнейшую инициализацию.
#

define ["clicks/forms", "clicks/anchors", "history", "events"], (forms, anchors, history, events) ->
  return false if not history

  #### handler()
  # Обработчик, вызывает событие "pageTransition:init"
  handler = (eventData) ->
    url = eventData.url ? null
    data = eventData.data ? []
    params = eventData.params ? {}
    method = eventData.method ? "GET"
    formData = eventData.formData ? []

    events.trigger "pageTransition:init", [url, data, method, formData, params]

  events.bind "pageTransition:success", (data) ->
    events.trigger "pageTransition:stop", data

  #### init()
  #
  # Основная инициализация, добавление обработчика к модулям,
  # работающим со специальными формами и ссылками
  #
  init = () ->
    forms handler
    anchors handler

  init.reset = ->
    forms.reset()
    anchors.reset()
    init()

  init()

  init