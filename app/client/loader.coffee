#### *module* loader
#
# Модуль для предварительной загрузки виджетов
#


define [
  "widgets"
  "config"
  "events"
  "lib/domReady"
  "utils/widgetsData"
  "underscore"
], (widgets, config, events, domReady, widgetsData, _) ->
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


  # по событию DOMContentLoaded запускает поиск виджетов
  domReady -> loader.search()

  loader
