#### *module* history
#
# Надстройка над historyAPI, необходима для создания событий истории, это хорошо понижает связность модулей.
# Кроме событий, модуль возвращает false, если historyAPI недоступно, это используется другими модулями, которые зависят от этого,
# в дальнейшем такое поведение нужно бы реализовать с помощью requirejs loaderAPI (например так сделано с модулем dom)
#

define ['events'], (events) ->
  return false if not window.history or not window.history.pushState

  class State
    constructor: (options = {}) ->
      @che = true
      @url = options.url or window.location.href
      @index = options.index or 0
      @method = options.method or "GET"
      @sections = options.sections
      @sectionsHeader = options.sectionsHeader or []
      @sectionsParams = options.sectionsParams or {}
      @scrollPos = {}
      @userReplaceState = true if options.replaceState
      @updateScroll options

    getScroll: ->
      top: window.pageYOffset or document.documentElement.scrollTop
      left: window.pageXOffset or document.documentElement.scrollLeft

    updateScroll: (options = {}) ->
      scrollPos = @getScroll()
      options.scrollPos = {} if !options.scrollPos?
      @scrollPos =
        top: options.scrollPos.top or scrollPos.top
        left: options.scrollPos.left or scrollPos.left

  ###
    Workaround with Chrome popsate on very first page load. Get idea from jquery.pjax
  ###
  initialUrl = window.location.href
  window.history.CheState = State
  popped = false

  originOnpopstate = window.onpopstate
  window.onpopstate = (popStateEvent)->
    initialPop = !popped and location.href is initialUrl
    popped = true
    return if initialPop

    if originOnpopstate?
      originOnpopstate.apply window, arguments

    if 'state' of popStateEvent
      events.trigger "history:popState", (popStateEvent.state if popStateEvent.state?)

  originPushState = window.history.pushState
  window.history.pushState = (state) ->
    originPushState.apply window.history, arguments
    events.trigger "history:pushState", Array::slice.call arguments

  originReplaceState = window.history.replaceState
  window.history.replaceState = (state) ->
    originReplaceState.apply window.history, arguments
    events.trigger "history:replaceState", Array::slice.call Array, arguments

  return window.history