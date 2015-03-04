#### *module* dom
#
# Содержит вспомогательные функции для обхода DOM-дерева,
# и навешивания обработчиков событий, позволяет обходится
# без большого jquery.
# Интерфейс стремится быть похожим на интефейс jquery,
# конечно реализация сильно отличается


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
  # Вызывает обработчики событий

  callEventHandlers = (handlers, eventObj, context) ->
    targetElement = context
    for handler in handlers
      result = handler.call context, eventObj, targetElement
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
            result = result.concat(Array::slice.call root.querySelectorAll(selector))
        return result
      else
        return selector
    else
      console?.log "haven't tools for selecting node (module helpers/dom)"


  #### unbindEvent(node, eventName, handler)
  #
  # Отвязывает обработчика от события для указанного DOM-элемента
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
  # Привязывает обработчик к событию для указанного DOM-элемента
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

      node.domQueryDelegateHandler = delegateHandler

    bindEvent node, eventName, node.domQueryDelegateHandler
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
    # return false if not handler.guid
    return false if not node.domQueryHandlers
    return false if not node.domQueryHandlers[eventName]
    return false if not node.domQueryHandlers[eventName][selector]
    handlers = node.domQueryHandlers[eventName][selector]
    index = null

    _.find handlers, (delegateHandler, handlerIndex) ->
      checkGuid = if delegateHandler.original then delegateHandler.original.guid else delegateHandler.guid
      index = handlerIndex
      checkGuid is handler.guid

    if index isnt null
      handlers.splice index, 1
      node.domQueryHandlers[eventName][selector] = handlers


  #### domToHtml(plainHtml)
  #
  # Сериализует DOM-объекты в html-текст
  #

  domToHtml = (domObject) ->
    div = document.createElement('DIV')
    div.appendChild domObject
    div.innerHTML

  #### parseHtml(plainHtml)
  #
  # Парсит html-текст в DOM-объекты
  #
  parseHtml = (plainHtml) ->
    div = document.createElement('DIV')
    div.innerHTML = plainHtml
    for node in Array::slice.call div.childNodes
      if node.nodeType is 3 and not ///\S///.test node.nodeValue
        div.removeChild node
    return div.childNodes


  #### domQuery([selector])
  #
  # Конструктор domQuery для работы с DOM-элементами. Если переданный параметр
  # уже является объектом domQuery, то просто возвращается этот экземпляр,
  # также проверяется вызван ли конструктор с ключевым словом new,
  # если нет, то рекурсивно вызывается конструктор вместе с new.
  # Если параметр selector является строкой, то проверятеся, не является ли он
  # html-строкой, если да, то парсится, если нет, то подразумевается,
  # что это dom-селектор и происходит поиск элементов, удовлетворяющих селектору.
  # Если selector не строка, то подразумевается, что это ссылка на dom-элемент,
  # либо на nodeList (пока проверок точных еще нет).
  # Если selector не задан, то вместо него берется ссылка на document.


  domQuery = (selector) ->
    if this instanceof domQuery
      return selector if selector instanceof domQuery
      if _.isString(selector)
        selector = selector.replace /^\s+|\s+$/g, ""
        if selector.charAt(0) is "<" and selector.charAt(selector.length - 1) is ">" and selector.length >= 3
          elements = parseHtml selector
        else
          elements = query selector
      else
        elements = selector or [document]

      if elements.elements?
        @length = 1
        @selector = selector
        @[0] = selector
        return

      if elements.length is undefined or elements.nodeType is 3
        elements = [elements]

      @length = elements.length
      @selector = selector
      _.each elements, (element, index) =>
        @[index] = element
      return undefined
    else
      new domQuery selector

  domQuery:: =


    #### domQuery::on([selector,] eventName, handler [,context])
    #
    # Привязывает обработчика событий на элемент, либо для делегирования
    # событий с элемента по селектору
    #
    on: (selectorOrEventName, eventNameOrHandler, handlerOrContext, context) ->
      argHanlderIndex = 2
      binder = delegateEvent

      if _.isFunction eventNameOrHandler
        # no selector given, so no delegate event
        binder = bindEvent
        argHanlderIndex--

      finalHandler = handler = arguments[argHanlderIndex]

      if arguments[(argHanlderIndex + 1)]?
        # with context
        handler.guid = handler.guid or guid()
        finalHandler = _.bind handler, arguments[(argHanlderIndex + 1)]
        finalHandler.original = handler

      args = Array::slice.call(arguments)
      args[argHanlderIndex] = finalHandler

      _.each @get() , (node, index) ->
        binder.apply @, [node].concat(args)
      @


    #### domQuery::off([selector], eventName, handler)
    #
    # Отключает обработчика событий элемента, либо от делегирования событий
    # с элемента по селектору
    #
    off: (selector, eventName, handler) ->
      unbinder = if arguments.length is 3 then undelegateEvent else unbindEvent
      args = Array::slice.call(arguments)
      _.each @get(), (node, index) ->
        unbinder.apply @, [node].concat args
      @

    #### domQuery::find(selector)
    #
    # Возвращает элемент по селектору в контексте экземпляра domQuery
    #
    find: (selector) ->
      return domQuery query selector, @get()


    #### domQuery::get([index])
    #
    # Возвращает элемент по идексу, либо массив элементов экземпляра domQuery
    #
    get: (index) ->
      if index?
        index = Math.max 0, Math.min index, @length - 1
        @[index]
      else
        return Array::slice.call @


    #### domQuery::toString([index])
    #
    # Сериализует элементы в строку
    #

    toString: () ->
      _.map @get(), (node) ->
        domToHtml node
      .join ""


    #### domQuery::replaceWith(element)
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
