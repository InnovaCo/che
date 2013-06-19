#### *module* clicks/anchors
#
# Обрабатывает клики по ссылкам с аттрибутом data-reload-sections,
# достает данные о необходимых секциях, url и вызывает обработчика, после чего отменяет дефолтное поведение
#

define ['dom!', 'config', 'events'], (dom, config, events) ->

  # Внутренний диспетчер событий, для вызова обработчиков клика
  clicks = null

  # Непосредственно навешивание обработчика, который работает
  # только если есть хоть один обработчик клика, на это указывает
  # наличие clicks

  dom('body').on "a[#{config.reloadSectionsDataAttributeName}],area[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
    return true if e.ctrlKey or e.altKey or e.shiftKey or e.metaKey
    if clicks?

      data = @getAttribute config.reloadSectionsDataAttributeName
      url = @getAttribute 'href'
      clicks.trigger "anchor:click",
        url: url,
        data: data,
        method: "GET"

      e.preventDefault()
      return false

  #### init(callback)
  #
  # Интерфейс модуля. Представляет функцию, которая принимает
  # обработчиков кликов.
  # Функция создает новый диспетчер событий, если до этого
  # его не было
  #
  init = (callback) ->
    if not clicks?
      clicks = events.sprout "anchors"

    clicks.bind "anchor:click", callback

  #### init.reset()
  #
  # Удаляет диспетчер событий, тем самым возвращая
  # к предыдущему состоянию
  #
  init.reset = ->
    clicks = null

  init