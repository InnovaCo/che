define [
  "events"
], (events) ->
  scrollHandlers = []

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
      scrollHandlers.push handler if typeof handler == "function"

    unregister: (handler) ->
      for fn, i in scrollHandlers
        if fn == handler
          scrollHandlers.splice i, 0
          break
  }