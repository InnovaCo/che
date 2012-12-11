#### *module* preloader
#
#---
# Модуль для предварительной загрузки виджетов
#

define 'preloader', ['dom', 'domReady'], (dom, domReady) ->
  widgetClassName = 'widget'
  widgetAttributName = 'data-js-module'

  ##### loadWidgetModule(domElement)
  #
  #---
  # загружает js-скрипты для виджета, на основе указанного data-аттрибута
  loadWidgetModule = (domElement) ->
    widgetName = domElement.getAttribute widgetAttributName
    if not widgetName
      return no
      
    require [widgetName], (widget) ->
      widget.init(domElement)

  ##### loadWidgetModule()
  #
  #---
  # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
  searchForWidgets = ->
    preloader.loadWidgetModule element for element in dom.getElementByClass widgetClassName

  # for easier module testing
  preloader =
    loadWidgetModule: loadWidgetModule,
    searchForWidgets: searchForWidgets

  domReady searchForWidgets
    
  preloader