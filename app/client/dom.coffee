#### *module* dom
#
# Содержит вспомогательные функции для обхода DOM-дерева, и навешивания обработчиков событий, чтобы не грузить большой jquery ради пары мелких задач
#

# Требует модуль 'utils/guid', для генерации уникальных id обработчиков событий

define ["utils/guid", "lib/domReady", "underscore"], (guid, domReady, _) ->

  
  #### checkIsElementMatchSelector(selector, element, [root])
  #
  # Проверяет, подходит ли указанный селектор для элемента
  
  checkIsElementMatchSelector = (selectorOrNodeList, element, root) ->
    return false if element is root or not element
    root = root or document
    list = if _.isString(selectorOrNodeList) then domQuery(root).find(selectorOrNodeList).get() else selectorOrNodeList
    for listElement in list
      return listElement if listElement is element

    return checkIsElementMatchSelector list, element.parentNode, root
  
  #### callEventHandlers(handlers, eventObj)
  #
  # Асинхронно вызывает обработчиков событий
  
  callEventHandlers = (handlers, eventObj, context) ->
    for handler in handlers
      result = handler.call context, eventObj
      if result is false
        return false
  
  #### query(selector, [root])
  #
  # Возвращает элементы для указанного селектора
  #
  query = (selector, root) ->
    if window.jQuery
      query = (selector, root) ->
        return window.jQuery(root or document).find(selector).get()

      return query.apply this, arguments

    if document.querySelectorAll?
      if _.isString selector
        root = if not root or root.length is 0 then document else root
        if not root.length
          root = [root]
        result = []
        _.each root, (root) ->
          if root.querySelectorAll?
            result = result.concat(Array.prototype.slice.call root.querySelectorAll(selector))
        return result
      else 
        return selector
    else
      console?.log "haven't tools for selecting node (module helpers/dom)"

  
  #### unbindEvent(node, eventName, handler)
  #
  # Отвязывает обработчика события для указанного DOM-элемента
  #
  unbindEvent =  (node, eventName, handler) ->
    if node.removeEventListener
      unbindEvent = (node, eventName, handler) ->
        node.removeEventListener eventName, handler, false
    else if node.detachEvent
      unbindEvent = (node, eventName, handler) ->
        node.detachEvent "on" + eventName, handler
    else
      return console?.log "cannot unbind event (module helpers/dom)"

    unbindEvent.apply this, arguments

  
  #### bindEvent(node, eventName, handler)
  #
  # Привязывает обработчик события для указанного DOM-элемента
  #
  bindEvent = (node, eventName, handler) ->
    if node.addEventListener
      bindEvent = (node, eventName, handler) ->
        node.addEventListener eventName, handler, false
    else if node.attachEvent
      bindEvent = (node, eventName, handler) ->
        node.attachEvent "on" + eventName, handler
    else
      return console?.log "cannot bind event (module helpers/dom)"

    bindEvent.apply this, arguments


  #### delegateEvent(node, selector, eventName, handler)
  #
  # Привязывает обработчика события на DOM-элемент, делегирует ему события с элементов по селектору
  #
  delegateEvent = (node, selector, eventName, handler) ->
    if not node.domQueryDelegateHandler
      delegateHandler = (e) ->
        eventObject = e or window.event
        target = eventObject.target or eventObject.srcElement
        if target.nodeType is 3 # defeat Safari bug
          target = target.parentNode
      
        if node.domQueryHandlers[eventObject.type]
          handlers = node.domQueryHandlers[eventObject.type]
          result = true
          _.each handlers, (handlers, selector) ->
            targetElement = checkIsElementMatchSelector selector, target, node
            if targetElement
              result = callEventHandlers handlers, eventObject, targetElement
          result

      bindEvent node, eventName, delegateHandler
      node.domQueryDelegateHandler = delegateHandler

    handler.guid = handler.guid or guid()
    node.domQueryHandlers = node.domQueryHandlers or {}
    node.domQueryHandlers[eventName] = node.domQueryHandlers[eventName] or {}
    node.domQueryHandlers[eventName][selector] = node.domQueryHandlers[eventName][selector] or []
    node.domQueryHandlers[eventName][selector].push handler

  
  #### undelegateEvent(node, selector, eventName, handler)
  #
  # Отвязывает обработчика от делегирования событий с элементов по селектору
  #
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

    if index isnt null
      handlers.splice index, 1
      node.domQueryHandlers[eventName][selector] = handlers

  #### parseHtml(plainHtml)
  #
  # Превращает html-текст в DOM-объекты
  #
  parseHtml = (plainHtml) ->
    div = document.createElement('DIV')
    div.innerHTML = plainHtml
    for node in Array.prototype.slice.call div.childNodes
      if node.nodeType is 3 and not ///\S///.test node.nodeValue
        div.removeChild node
    return div.childNodes


  #### domQuery([selector])
  #
  # Конструктор domQuery для работы с DOM-элементами
  #
  domQuery = (selector) ->
    if this instanceof domQuery
      return selector if selector instanceof domQuery
      if _.isString(selector)
        selector = selector.replace /^\s+|\s+$/, ""
        if selector.charAt(0) is "<" and selector.charAt(selector.length - 1) is ">" and selector.length >= 3
          elements = parseHtml selector
        else
          elements = query selector
      else
        elements = selector or [document]

      if elements.length is undefined or elements.nodeType is 3
        elements = [elements]

      @length = elements.length
      @selector = selector
      _.each elements, (element, index) =>
        @[index] = element
    else
      new domQuery selector

  domQuery:: =

    
    #### domQuery.prototype.on([selector], eventName, handler)
    #
    # Привязывает обработчика событий на элемент, либо для делегирования событий с элемента по селектору
    #
    on: (selector, eventName, handler) ->
      binder = if arguments.length is 3 then delegateEvent else bindEvent
      args = Array.prototype.slice.call(arguments)
      _.each @get() , (node, index) ->
        binder.apply @, [node].concat(args)
      @

    
    #### domQuery.prototype.off([selector], eventName, handler)
    #
    # Отключает обработчика событий элемента, либо от делегирования событий с элемента по селектору
    #
    off: (selector, eventName, handler) ->
      unbinder = if arguments.length is 3 then undelegateEvent else unbindEvent
      args = Array.prototype.slice.call(arguments)
      _.each @get(), (node, index) ->
        unbinder.apply @, [node].concat args
      @
    
    #### domQuery.prototype.find(selector)
    #
    # Возвращает элемент по селектору в контексте экземпляра domQuery
    #
    find: (selector) ->
      return domQuery query selector, @get()


    #### domQuery.prototype.get([index])
    #
    # Возвращает элемент по идексу, либо массив элементов экземпляра domQuery
    #
    get: (index) ->
      if index?
        index = Math.max 0, Math.min index, @length - 1
        @[index]
      else
        return Array.prototype.slice.call @


    #### domQuery.prototype.replaceWith(element)
    #
    # заменяет первый элемент на указанный
    #
    replaceWith: (element) ->
      @[0] = @[0].parentNode.replaceChild element[0] or element, @[0]


  domQuery.load = (name, req, onLoad, config) ->
    domReady.load name, req, () ->
        onLoad domQuery
      , config
    domQuery
        
  domQuery
