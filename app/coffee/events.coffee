define [], ->
  Oops = (name) ->
    if events.list[name]
      return events.list[name]
    @name = name
    @_handlers = {}
    events.list[@name] = @
  Oops:: =
    _data: ->
      name: @name
    _handlerCaller: (handler)->
      result = handler.apply handler.context, @_lastArgs
      # to stop propagation
      if result is false
        @_handlersCallOrder = []

    _nextHandlerCall: ->
      handlerId = @_handlersCallOrder.shift()
      if handlerId
        handler = @_handlers[handlerId]
        self = @
        if handler.options.isSync
          @_handlerCaller handler
        else
          _.delay -> 
            self._handlerCaller handler
        @_nextHandlerCall()


    dispatch: (args) -> 
      @_handlersCallOrder = _.keys(@_handlers).sort()
      @_lastArgs = if _.isArray(args) then args else [args]
      @_lastArgs.push this._data()

      @_nextHandlerCall()
      @

    bind: (handler, context, options) ->
      handler.id = handler.id or +_.uniqueId()
      handler.context = context
      handler.options = handler.options or options or {}
      @_handlers[handler.id] = handler
      if handler.options.recall and @_lastArgs
        @_handlerCaller handler
      @

    once: (handler, context, options) ->
      self = @
      onceHandler = ->
        events.unbind self.name, onceHandler
        handler.apply this, arguments
        
      @bind onceHandler, context, options
      @

    unbind: (handler) ->
      id = handler.id
      if id and @_handlers[id]
        delete  @_handlers[id]
      @

  events =
    list: {}
    create: (name) ->
      new Oops(name)

    once: (name, handler, context, options) ->
      new Oops(name).once(handler, context, options)
      
    bind: (eventsNames, handler, context, options) ->
      bindEventsList = _.compact eventsNames.split ///\,+\s*|\s+///
      if ///\,+///.test eventsNames
        compoundArguments = {}
        undispatchedEvents = bindEventsList.concat []
        eventHandler = () ->
          eventData = _.last arguments
          compoundArguments[eventData.name] = arguments
          if _.contains undispatchedEvents, eventData.name
            undispatchedEvents = _.without undispatchedEvents, eventData.name
          if undispatchedEvents.length == 0
            undispatchedEvents = bindEventsList.concat []
            handler.call this, compoundArguments
      else
        eventHandler = handler

      for eventName in bindEventsList
        do (eventName) ->
          new Oops(eventName).bind eventHandler, context, options

      new Oops(bindEventsList[0])

    unbind: (name, handler) ->
      new Oops(name).unbind(handler)

    trigger: (name, args) ->
      new Oops(name).dispatch(args)

  events