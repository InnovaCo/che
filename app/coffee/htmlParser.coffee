#### *module* htmlParser
#
# Модуль для получения данных о необходимых модулях из dom-элементов, либо html-текста
#

# Требует модуль 'dom' для прохода по DOM-элеметам

define ['dom', 'config'], (dom, config) ->
  #### createDomElement(plainHtml)
  #
  # превращает html-текст в dom-элемент, оборачивает в div
  createDomElement = (plainHtml) ->
    div = document.createElement('DIV')
    div.innerHTML = plainHtml
    return div

  
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

  
 
  parser = (html) ->
    return  _.isString html then createDomElement html else html
    
  #### parser.getWidgets(html)
  #
  # ищет все блоки виджетов внутри dom-элемента, либо просто текста в формате html и возвращает массив пар {name: 'moduleName', element: 'domElement'}
  parser.getWidgets = (domElement) ->
    domElement = parser domElement
    arrayOfPairs = []
    for element in getWidgetElements domElement
      saveTo arrayOfPairs, element

    arrayOfPairs

  # exposing for testing
  parser._save = saveTo
  parser


