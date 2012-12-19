beforeEach ->
  @addMatchers 
    toBeFunction: ->
      _.isFunction(@actual)

    toBeArray: ->
      _.isArray(@actual)

    toBeEmpty: ->
      _.isEmpty(@actual)

    toBeObject: ->
      _.isObject(@actual)

    toBeEqual: ->
      _.isEqual(@actual)