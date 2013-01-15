define ['events', 'dom'], (events, dom) ->
  if window.history?
    originOnpopstate = window.onpopstate
    window.onpopstate = (popStateEvent)->
      if originOnpopstate?
        originOnpopstate.apply window, arguments

      events.trigger "history:popState", popStateEvent.state

    originPushState = window.history.pushState

    window.history.pushState = ->
      console.log arguments, Array::slice.call arguments
      originPushState.apply window.history, arguments
      events.trigger "history:pushState", Array::slice.call arguments

    originReplaceState = window.history.pushState

    window.history.replaceState = ->
      originReplaceState.apply window.history, arguments
      events.trigger "history:replaceState", Array::slice.call Array, arguments

    return window.history
  else
    return false


  HashHistory = () ->

  HashHistory:: =
    length: 0
    state: null
    go: (n) -> # Метод, позволяющий гулять по истории. В качестве аргумента передается смещение, относительно текущей позиции. Если передан 0, то будет обновлена текущая страница. Если индекс выходит за пределы истории, то ничего не произойдет.
    back: () -> # Метод, идентичный вызову go(-1)
    forward: () -> # Метод, идентичный вызову go(1)
    pushState: (data, title, url) -> # Добавляет элемент истории.
    replaceState: (data, title, url) -> # Обновляет текущий элемент истории  
