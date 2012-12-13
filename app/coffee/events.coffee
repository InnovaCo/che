define [], ->
  eventsData =
    handlers: {}
    previousArgs: {}

  handlerCall = (handler, eventName, args) ->
    eventData =
      name: eventName
    handlerArgs = if _.isArray(args) then args else [args]
    handlerArgs.push eventData
    if handler.options.isSync
      handler.apply eventData, handlerArgs
      return "sync"
    else 
      _.delay ->
        handler.apply eventData, handlerArgs
      return "async"

  bindHandlerToEvent = (eventName, handler, options) ->
    handler.id = handler.id or _.uniqueId eventName + "_handler_"
    handler.options = handler.options or options or {}
    eventsData.handlers[eventName] = eventsData.handlers[eventName] or {}
    eventsData.handlers[eventName][handler.id] = handler

    if eventsData.previousArgs[eventName] and options.remember
      handlerCall handler, eventName, eventsData.previousArgs[eventName]

  events =
    _data: eventsData
    once: (eventName, handler, options) ->
      onceHandler = ->
        handler.apply(this, arguments)
        events.unbind eventName, onceHandler
      onceHandler.id = _.uniqueId eventName + "_once_handler_"
      events.bind eventName, onceHandler, options
      
    bind: (eventsNames, handler, options) ->
      eventsList = _.compact eventsNames.split ///\,+\s*|\s+///
      if ///\,+///.test eventsNames  
        compoundArguments = {}
        eventHandler = () ->
          eventData = @
          compoundArguments[eventData.name] = arguments
          if _.contains eventsList, eventData.name
            eventsList = _.without eventsList, eventData.name
          if eventsList.length == 0
            handler.call this, compoundArguments
      else
        eventHandler = handler

      for eventName in eventsList
        do (eventName) ->
          bindHandlerToEvent eventName, eventHandler, options
          

    unbind: (eventName, handler) ->
      id = handler.id
      if id and eventsData.handlers[eventName] and eventsData.handlers[eventName][id]
        delete eventsData.handlers[eventName][id]

    trigger: (eventName, args, options) ->
      
      handlersList = eventsData.handlers[eventName] or {}
      eventsData.previousArgs[eventName] = args
      caller = (handler) ->
        handlerCall handler, eventName, args

      _.each handlersList, caller


  events.pub = events.trigger
  events.sub = events.bind
  events.unsub = events.unbind

  events