#### *module* utils/destroyer
#
#---
# Модуль для уничтожения объекта, рекурсивно (при указании параметра is_deep) и асинхронно удаляет все свойства объекта (удаляются ссылки на объекты, а не сами объекты)
# Рекурсивное удаление следует использовать с осторожностью, так как оно также уничтожает объекты, на которые есть ссылки.
# Для рекурсивного удаления еще нужно дописать инструкции, чтобы хорошо и быстро уничтожать dom-объекты, вот тут рассказано про это: http://stackoverflow.com/questions/3785258/how-to-remove-dom-elements-without-memory-leaks

define [], ->
  destroyer = (object, is_deep) ->
    _.each object, (property, name) ->
      if object.hasOwnProperty name
        if is_deep and _.isObject property
          _.delay destroyer, property

        delete object[name]

  destroyer