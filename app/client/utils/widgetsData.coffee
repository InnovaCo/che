#### *module* utils/widgetsData
#
# Вытаскивает данные о необходимых виджетах для данного куска html, либо DOM-элемента.
# Возвращает массив объектов с полями element, в котором содержится DOM-элемент и name, где находится имя модуля.
# Далее эти данные могут быть переданы в модуль widgets, чтобы проинициализировать все модули.
#

define ['dom', 'config'], (dom, config) ->
  
  #### saveTo(arrayOfPairs, element)
  #
  # сохраняет в массив данные о виджете для переданного элемента
  #
  saveTo = (arrayOfPairs, element) ->
    names = null
    if element and element.getAttribute?
      names = (element.getAttribute config.widgetDataAttributeName)?.replace(/^\s|\s$/, '').split(/\s*,\s*/)

    return false if not names

    for moduleName in names
      arrayOfPairs.push
        name: moduleName
        element: element

    arrayOfPairs

  #### getWidgets(node)
  #
  # Возвращает набор пар с именем виджета и ссылкой на DOM-элемент
  #
  getWidgets = (node) ->
    pairs = []

    if node and node isnt document
      root = dom node
      for rootElement in root
        saveTo pairs, rootElement
    else
      root = dom document

    widgetElements = root.find("[#{config.widgetDataAttributeName}]").get()

    for element in widgetElements
      saveTo pairs, element
    pairs

  getWidgets
