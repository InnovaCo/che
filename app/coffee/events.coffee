define "events", [], ->
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

  events =
    _data: eventsData
    once: (eventName, handler, options) ->
      onceHandler = ->
        handler.apply(this, arguments)
        events.unbind eventName, onceHandler
      onceHandler.id = _.uniqueId eventName + "_once_handler_"
      events.bind eventName, onceHandler, options
      
    bind: (eventName, handler, options) ->
      handler.id = handler.id or _.uniqueId eventName + "_handler_"
      handler.options = options or {}
      eventsData.handlers[eventName] = eventsData.handlers[eventName] or {}
      eventsData.handlers[eventName][handler.id] = handler

      if eventsData.previousArgs[eventName] and options.remember
        handlerCall handler, eventName, eventsData.previousArgs[eventName]
          

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