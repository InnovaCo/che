define [
  "events"
], (events) ->
  scrollHandlers = []
  findHandler = (handler) ->
    for fn, i in scrollHandlers
      if fn == handler
        return i
    return

  return {
    _handlers: scrollHandlers

    process: (transition) ->
      scrollPos = transition.state?.scrollPos or {}
      events.trigger "scrollHandlers:prepare", transition

      if (transition.state? and !transition.state.userReplaceState and !transition.next_transition)
        for handler in scrollHandlers
          result = handler(scrollPos, transition) or {}
          scrollPos.top = result.top if result.top?
          scrollPos.left = result.left if result.left?

        transition.state.scrollPos = scrollPos
      scrollPos

    register: (handler) ->
      if typeof handler == "function" and !(findHandler handler)?
        scrollHandlers.push handler

    unregister: (handler) ->
      handlerIndex = findHandler handler
      scrollHandlers.splice handlerIndex, 1 if handlerIndex?
  }