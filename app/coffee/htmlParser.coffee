#### *module* htmlParser
#
#---
# Модуль для получения данных о необходимых модулях из dom-элементов, либо html-текста
#

define ['dom'], (dom) ->
  widgetClassName = 'widget'
  widgetAttributName = 'data-js-module'

  ##### createDomElement(plainHtml)
  #
  #---
  # превращает html-текст в dom-элемент, оборачивает в div
  createDomElement = (plainHtml) ->
    div = document.createElement('DIV')
    div.innerHTML = plainHtml
    return div

  ##### getWidgetElements(domElement)
  #
  #---
  # возаращает все элементы, для которых могут понадобится js-модули
  getWidgetElements = (domElement) ->
    dom(domElement).find("." + widgetClassName).get()


  ##### saveTo(arrayOfPairs, element)
  #
  #---
  # сохраняет в массив данные о виджете для переданного элемента
  saveTo = (arrayOfPairs, element) ->
    names = (element.getAttribute widgetAttributName).replace(///^\s|\s$///, '').split(///\s*,\s*///)
    for moduleName in names
      arrayOfPairs.push
          name: moduleName
          element: element

    arrayOfPairs

  ##### parser(html)
  #
  #---
  # ищет все блоки виджетов внутри dom-элемента, либо просто текста в формате html и возвращает массив пар {name: 'moduleName', element: 'domElement'}
  parser = (html) ->
    domElement = if _.isString html then createDomElement html else html
    arrayOfPairs = []
    for element in getWidgetElements domElement
      saveTo arrayOfPairs, element

    arrayOfPairs

  # exposing for testing
  parser._save = saveTo
  parser


