define ['events', 'dom'], (events, dom) ->
  return false if not window.history

  originOnpopstate = window.onpopstate
  window.onpopstate = (popStateEvent)->
    if originOnpopstate?
      originOnpopstate.apply window, arguments

    events.trigger "history:popState", popStateEvent.state

  originPushState = window.history.pushState

  window.history.pushState = ->
    originPushState.apply window.history, arguments
    events.trigger "history:pushState", Array::slice.call arguments

  originReplaceState = window.history.pushState

  window.history.replaceState = ->
    originReplaceState.apply window.history, arguments
    events.trigger "history:replaceState", Array::slice.call Array, arguments

  return window.history