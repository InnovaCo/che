#### *module* loader
#
# Модуль для предварительной загрузки виджетов
#


define [
  'widgets',
  'config',
  'events'
  'utils/widgetsData',
  'underscore',
  'dom!',
  ], (widgets, config, events, widgetsData, _) ->
   # Интерфейс модуля, вынесены локальные функции для более удобного тестирования

  loader =
    #### widgets(listWidgetsData)
    #
    # загружает js-скрипты для виджетов
    #
    widgets: (listWidgetsData, ready) ->
      widgetsCount = _.keys(listWidgetsData).length
      list = []
      if widgetsCount is 0
        ready?(list)
      else
        for data in listWidgetsData
          widgets.create data.name, data.element, (widget) ->
            list.push widget
            widgetsCount -= 1
            if widgetsCount is 0
              ready?(list, listWidgetsData)

    #### search(node)
    #
    # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
    #
    search: (node, ready) ->
      loader.widgets widgetsData(node), ready


  # сразу запускает поиск виджетов
  loader.search()

  loader