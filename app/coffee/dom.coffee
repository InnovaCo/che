#### *module* helpers/dom
#
#---
# Содержит вспомогательные функции для обхода DOM-дерева пока jquery еще не готов
#

define ["utils/guid"], (guid) ->

  checkIsElementMatchSelector = (selector, element) ->
    listOfElemevents = domQuery(selector).get()
    _.find listOfElemevents, (elementFromlist) ->
      _.isEqual(elementFromlist, element)

  callEventHandlers = (handlers, eventObj) ->
    _.each handlers, (handler) ->
      _.delay(handler, eventObj)

  query = (selector, root) ->
    if document.querySelectorAll?
      query = (selector, root) ->
        if _.isString selector
          root = if not root or root.length is 0 then document else root
          if not root.length
            root = [root]
          result = []
          _.each root, (root) ->
            result = result.concat(Array.prototype.slice.call root.querySelectorAll(selector))
          return result
        else 
          return selector
    else
      query = ->
        console?.log "haven't tools for selecting node (module helpers/dom)"

    query.apply this, arguments

  unbindEvent =  ->
  bindEvent = (node, eventName, handler) ->
    if node.addEventListener
      bindEvent = (node, eventName, handler) ->
        node.addEventListener eventName, handler, false
      unbindEvent = (node, eventName, handler) ->
        node.removeEventListener eventName, handler, false
    else if node.attachEvent
      bindEvent = (node, eventName, handler) ->
        node.attachEvent "on" + eventName, handler
      unbindEvent = (node, eventName, handler) ->
        node.detachEvent eventName, handler
    else
      bindEvent = ->
        console?.log "cannot bind event (module helpers/dom)"

    bindEvent.apply this, arguments

  
  delegateEvent = (node, selector, eventName, handler) ->
    if not node.domQueryDelegateHandler
      delegateHandler = (e) ->
        eventObject = e or window.event
        target = eventObject.target or eventObject.srcElement
        if target.nodeType is 3 # defeat Safari bug
          target = target.parentNode
        
        if node.domQueryHandlers[eventObject.type]
          handlers = node.domQueryHandlers[eventObject.type]
          _.each handlers, (handlers, selector) ->
            if checkIsElementMatchSelector selector, target
              callEventHandlers handlers, eventObject

      bindEvent node, eventName, delegateHandler
      node.domQueryDelegateHandler = delegateHandler

    handler.guid = handler.guid or guid()
    node.domQueryHandlers = node.domQueryHandlers or {}
    node.domQueryHandlers[eventName] = node.domQueryHandlers[eventName] or {}
    node.domQueryHandlers[eventName][selector] = node.domQueryHandlers[eventName][selector] or []
    node.domQueryHandlers[eventName][selector].push handler

  undelegateEvent = (node, selector, eventName, handler) ->
    return false if not handler.guid
    return false if not node.domQueryHandlers
    return false if not node.domQueryHandlers[eventName]
    return false if not node.domQueryHandlers[eventName][selector]
    handlers = node.domQueryHandlers[eventName][selector]
    index = null
    _.find handlers, (delegateHandler, handlerIndex) ->
      index = handlerIndex
      delegateHandler.guid is handler.guid

    if index
      node.domQueryHandlers[eventName][selector] handlers.splice index, 1


  domQuery = (selector) ->
    if not domQuery::_forget_jquery and window.jQuery
      domQuery = window.jQuery
      return domQuery.apply this, arguments

    if this instanceof domQuery
      elements = query selector or []
      self = @
      if elements.length is undefined
        elements = [elements]
      @length = elements.length
      _.each elements, (element, index) ->
        self[index] = element
    else
      new domQuery selector

  domQuery:: =
    _forget_jquery: window.FORGET_JQUERY #for testing

    on: (selector, eventName, handler) ->
      binder = if arguments.length is 3 then delegateEvent else bindEvent
      args = Array.prototype.slice.call(arguments)
      _.each @get() , (node, index) ->
        binder.apply @, [node].concat(args)

    off: (selector, eventName, handler) ->
      unbinder = if arguments.length is 3 then undelegateEvent else unbindEvent
      args = Array.prototype.slice.call(arguments)
      _.each @get(), (node, index) ->
        unbinder.apply @, [node].concat(args)

    find: (selector) ->
      if not domQuery::_forget_jquery and window.jQuery
        return window.jQuery(@get()).find selector
      else
        return domQuery query selector, @get()

    get: (index) ->
      if index?
        index = Math.max 0, Math.min index, @length - 1
        @[index]
      else
        return Array.prototype.slice.call @
        
        
  domQuery
