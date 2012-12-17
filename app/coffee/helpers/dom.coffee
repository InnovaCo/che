#### *module* helpers/dom
#
#---
# Содержит вспомогательные функции для обхода DOM-дерева пока jquery еще не готов
#

define ->
  #### getElementByClass(elements, attribute_name)
  #
  #---
  # Возвращает элементы определенного класса внутри указанного узла, либо из документа
  #
  getElementsByClass = (class_name, node) ->
    node = node or document
    
    if node.getElementsByClassName
      getElementsByClass = (class_name, node) ->
        (node or document).getElementByClassName class_name

      return node.getElementsByClassName class_name
    else
      classElements = []
      elements = node.getElementsByTagName "*"
      pattern = new RegExp "(^|\\s)" + class_name + "(\\s|$)"
      classElements.push element for element in elements when pattern.test element.className
      return classElements
        

  getElementsByClass: getElementsByClass