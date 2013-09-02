#### *module* history
#
# Надстройка над historyAPI, необходима для создания событий истории, это хорошо понижает связность модулей.
# Кроме событий, модуль возвращает false, если historyAPI недоступно, это используется другими модулями, которые зависят от этого,
# в дальнейшем такое поведение нужно бы реализовать с помощью requirejs loaderAPI (например так сделано с модулем dom)
#

define ["events"], (events) ->
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
  blockHashEvent = false
  popped = false

  originOnPopState = window.onpopstate
  window.onpopstate = (popStateEvent) ->
    initialPop = !popped and location.href is initialUrl
    popped = true
    return if initialPop

    if originOnPopState?
      originOnPopState.apply window, arguments

    if 'state' of popStateEvent
      if popStateEvent.state?
        if popStateEvent.state.che
          blockHashEvent = true
        events.trigger "history:popState", popStateEvent.state
      else
        blockHashEvent = true
        events.trigger "history:popState"

  originOnHashChange = window.onhashchange
  window.onhashchange = () ->
    if originOnHashChange?
      originOnHashChange.apply window, arguments

    events.trigger "history:popState" if !blockHashEvent
    blockHashEvent = false

  originPushState = window.history.pushState
  window.history.pushState = (state) ->
    # При создании нового роута проставляем `popped` так как во всех браузерах кроме Хрома при
    # возвращении назад мы попадем на изначальную страницу и переход не сработает так как браузер
    # попадет под условие `return if initialPop`.
    popped = true
    originPushState.apply window.history, arguments
    events.trigger "history:pushState", Array::slice.call arguments

  originReplaceState = window.history.replaceState
  window.history.replaceState = (state) ->
    originReplaceState.apply window.history, arguments
    events.trigger "history:replaceState", Array::slice.call Array, arguments

  return window.history