#### *module* helpers/dom
#
#---
# Содержит вспомогательные функции для обхода DOM-дерева пока jquery еще не готов
#

define 'dom', ->
  #### getElementByClass(elements, attribute_name)
  #
  #---
  # Возвращает элементы определенного класса внутри указанного узла, либо из документа
  #
  getElementByClass = (class_name, node) ->
    node = node or document
    
    if node.getElementByClassName
      getElementByClass = (class_name, node) ->
        (node or document).getElementByClassName class_name

      return node.getElementByClassName class_name
    else
      classElements = []
      elements = node.getElementsByTagName "*"
      pattern = new RegExp "(^|\\s)" + class_name + "(\\s|$)"
      classElements.push element for element in elements when pattern.test element.className
      return classElements
        

  getElementByClass: getElementByClass