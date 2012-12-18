define [], ->
  (object) ->
    _.each object, (property, name) ->
      if object.hasOwnProperty name
        if _.isObject(property)
          _.delay destroyer, property
        delete object[name]
          