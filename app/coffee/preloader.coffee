#### *module* preloader
#
#---
# Модуль для предварительной загрузки виджетов
#

define ['lib/domReady', 'htmlParser'], (domReady, htmlParser) ->

  ##### loadWidgetModule(widgetData)
  #
  #---
  # загружает js-скрипты для виджета, на основе данных о виджете
  loadWidgetModule = (widgetData) ->
    require [widgetData.name], (widget) ->
      widget.init(widgetData.element)

  ##### loadWidgetModule()
  #
  #---
  # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
  searchForWidgets = ->
    preloader.loadWidgetModule widgetData for widgetData in htmlParser(document)

  # for easier module testing
  preloader =
    loadWidgetModule: loadWidgetModule,
    searchForWidgets: searchForWidgets

  domReady searchForWidgets
    
  preloader