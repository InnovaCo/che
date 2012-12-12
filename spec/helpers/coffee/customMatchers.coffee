beforeEach ->
  @addMatchers 
    toBeFunction: ->
      _.isFunction(@actual)

    toBeArray: ->
      _.isArray(@actual)