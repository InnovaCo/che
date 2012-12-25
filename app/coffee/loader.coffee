#### *module* loader
#
# Модуль для предварительной загрузки виджетов
#

# Требует модули htmlParser для поиска данных о необходимых модулях виджетов и widgets для их инициализации

define [
  'htmlParser',
  'widgets',
  'utils/ajax',
  'config',
  'events'
  ], (htmlParser, widgets, ajax, config, events) ->
  
  #### loadWidgetModule(widgetData)
  #
  # загружает js-скрипты для виджета, на основе данных о виджете
  loadWidgetModule = (widgetData) ->
    widgets.create widgetData.name, widgetData.element

  
  #### searchForWidgets(node)
  #
  # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
  searchForWidgets = (node) ->
    loader.loadWidgetModule widgetData for widgetData in htmlParser.getWidgets(node or document)

  # Интрефейс модуля, вынесены локальные функции для более удобного тестирования
  loader =
    loadWidgetModule: loadWidgetModule,
    searchForWidgets: searchForWidgets