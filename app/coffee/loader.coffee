#### *module* loader
#
#---
# Модуль для предварительной загрузки виджетов
#

define ['htmlParser', 'widgets'], (htmlParser, widgets) ->

  ##### loadWidgetModule(widgetData)
  #
  #---
  # загружает js-скрипты для виджета, на основе данных о виджете
  loadWidgetModule = (widgetData) ->
    widgets.create widgetData

  ##### searchForWidgets()
  #
  #---
  # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
  searchForWidgets = (node) ->
    loader.loadWidgetModule widgetData for widgetData in htmlParser(node or document)

  # for easier module testing
  loader =
    loadWidgetModule: loadWidgetModule,
    searchForWidgets: searchForWidgets