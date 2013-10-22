define ->
  clickHandlers = []
  findHandler = (handler) ->
    for fn, i in clickHandlers
      if fn == handler
        return i
    return

  return {
    _handlers: clickHandlers

    process: (data) ->
      for handler in clickHandlers
        if (handler data) == false
          return false

    register: (handler) ->
      if typeof handler == "function" and !(findHandler handler)?
        clickHandlers.push handler

    unregister: (handler) ->
      handlerIndex = findHandler handler
      clickHandlers.splice handlerIndex, 1 if handlerIndex?
  }