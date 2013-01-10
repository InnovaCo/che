#### *module* loader
#
# Модуль для предварительной загрузки виджетов
#

# Требует модули htmlParser для поиска данных о необходимых модулях виджетов и widgets для их инициализации

define [
  'dom',
  'widgets',
  'ajax',
  'config',
  'events'
  ], (dom, widgets, ajax, config, events) ->

  
  #### getWidgetElements(domElement)
  #
  # возаращает все элементы, для которых могут понадобится js-модули
  getWidgetElements = (domElement) ->
    dom(domElement).find("." + config.widgetClassName).get()


  
  #### saveTo(arrayOfPairs, element)
  #
  # сохраняет в массив данные о виджете для переданного элемента
  saveTo = (arrayOfPairs, element) ->
    names = (element.getAttribute config.widgetDataAttributeName).replace(///^\s|\s$///, '').split(///\s*,\s*///)
    for moduleName in names
      arrayOfPairs.push
          name: moduleName
          element: element

    arrayOfPairs

  
  #### loadWidgetModule(widgetData)
  #
  # загружает js-скрипты для виджета, на основе данных о виджете
  loadWidgetModule = (widgetData) ->
    widgets.create widgetData.name, widgetData.element

  
  #### searchForWidgets(node)
  #
  # ищет все блоки виджетов и отдает их на загрузку в loadWidgetModule
  searchForWidgets = (node) ->
    pairs = []
    for element in getWidgetElements node or document
      saveTo pairs, element

    loader.loadWidgetModule widgetData for widgetData in pairs

  # Интрефейс модуля, вынесены локальные функции для более удобного тестирования
  loader =
    loadWidgetModule: loadWidgetModule,
    searchForWidgets: searchForWidgets