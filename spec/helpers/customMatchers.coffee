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

    toBeEqual: (expecting)->
      _.isEqual(@actual, expecting)

    toBeDomElement: () ->
      return @actual.nodeType is 1 and @actual.nodeName? and @actual.nodeType?