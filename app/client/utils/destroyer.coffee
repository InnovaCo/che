#### *module* utils/destroyer
#
#---
# Модуль для уничтожения объекта, рекурсивно и асинхронно удаляет все свойства объекта
#

define [], ->
  destroyer = (object) ->
    _.each object, (property, name) ->
      if object.hasOwnProperty name
        if _.isObject(property)
          _.delay destroyer, property
        delete object[name]

  destroyer