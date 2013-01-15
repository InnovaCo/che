#### *module* loader
#
# Модуль для предварительной загрузки виджетов
#


define [
  'widgets',
  'config',
  'utils/widgetsData',
  'lib/domReady'
  ], (widgets, config, widgetsData, domReady) ->
  
  #### loadWidgetModule(widgetData)
  #
  # загружает js-скрипты для виджета, на основе данных о виджете
  loadWidgetModule = (widgetData) ->
    widgets.create widgetData.name, widgetData.element

  #### searchForWidgets(node)
  #
  # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
  #
  searchForWidgets = (node) ->
    loader.loadWidgetModule widgetData for widgetData in widgetsData node

  
  # Интрефейс модуля, вынесены локальные функции для более удобного тестирования
  loader =
    loadWidgetModule: loadWidgetModule,
    searchForWidgets: searchForWidgets

  # сразу запускает поиск виджетов
  domReady searchForWidgets

  loader