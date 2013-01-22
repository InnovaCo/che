#### *module* events
#
# Модуль событий приложения, полезен для понижения связности модулей
#

define [], ->

  
  #### Oops(name)
  #
  # Конструктор события, возвращает уже созданное, если такое уже есть
  #
  Oops = (name) ->
    @name = name
    @_handlers = {}
    @

  Oops:: =

    
    ####  Oops.prototype._data()
    #
    # Создает данные о событии для передачи обработчику
    _data: ->
      name: @name

    
    ####  Oops.prototype._handlerCaller
    #
    # Вызывает очередного обработчика, прерывает цепочку, если обаботчик вернул false
    #
    _handlerCaller: (handler)->
      result = handler.apply handler.context, @_lastArgs
      # to stop propagation
      if result is false
        @_handlersCallOrder = []

    
    ####  Oops.prototype._nextHandlerCall
    #
    # Достает очередного обработчика события и передает его для вызова
    #
    _nextHandlerCall: ->
      handlerId = @_handlersCallOrder.shift()
      if handlerId
        handler = @_handlers[handlerId]
        self = @
        if handler.options.isSync
          @_handlerCaller handler
        else
          _.delay -> 
            self._handlerCaller handler
        @_nextHandlerCall()

    
    ####  Oops.prototype.dispatch(args)
    #
    # Запускает исполнение обработчиков события
    #
    dispatch: (args) -> 
      @_handlersCallOrder = _.keys(@_handlers).sort()
      @_lastArgs = if _.isArray(args) then args else [args]
      @_lastArgs.push this._data()

      @_nextHandlerCall()
      @

    
    ####  Oops.prototype.bind(handler, context, [options])
    #
    # Привязывает обработчика к событию
    #
    bind: (handler, context, options) ->
      handler.id = handler.id or +_.uniqueId()
      handler.context = context
      handler.options = handler.options or options or {}
      @_handlers[handler.id] = handler
      if handler.options.recall and @_lastArgs
        @_handlerCaller handler
      @

    
    ####  Oops.prototype.once(handler, [context], [options])
    #
    # Привязывает обработчика к событию, который исполнится только один раз
    #
    once: (handler, context, options) ->
      self = @
      onceHandler = ->
        self.unbind onceHandler
        handler.apply this, arguments
        
      @bind onceHandler, context, options
      @

    
    ####  Oops.prototype.unbind(handler)
    #
    # Отвязывает обработчика от события
    #
    unbind: (handler) ->
      id = handler.id
      if id and @_handlers[id]
        delete  @_handlers[id]
      @

  window.evnts = []

  ####  Events
  #
  # Конструктор для шин событий, может создавать новые шины, которые могут наследовать родительские события
  #
  Events = (@_id) ->
    ####  events.list
    #
    # Список событий
    #
    @list = {}
    @

  Events:: =
    
    ####  Events::sprout([name], [inherit])
    #
    # Отпочковывает объект событий, если указано имя [name], 
    # то сохраняет ссылку на дочений объект в поле родительского по указанному имени, 
    # если указан параметр [inherit], то сохранает в дочернем объекте ссылку на родительский в поле parent,
    # после этого дочерний может обращаться к родительскому за Oops объектами (при вызове create)
    #
    sprout: (name) ->
      instance = new Events()
      if name?
        @[name] = instance

      instance
      
    ####  Events::create(name)
    #
    # Создает новое событие, либо отдает уже созданное
    #
    create: (name) ->
      if @_id is "root" then window.evnts.push(_.keys(@list).join(""))
      @list[name] = @list[name] or new Oops name

    
    ####  Events::once(name, handler, [context], [options])
    #
    # Создает новое событие, либо отдает уже созданное и привязывает обработчика, который сработает только один раз
    #
    once: (name, handler, context, options) ->
      @create(name).once(handler, context, options)
    
    
    ####  Events::bind(eventsNames, handler, [context], [options])
    #
    # Создает новое событие (может быть и несколько, если в eventsNames указаны имена через запятую), либо отдает уже созданное и привязывает обработчика
    #
    bind: (eventsNames, handler, context, options) ->
      bindEventsList = _.compact eventsNames.split ///\,+\s*|\s+///
      if ///\,+///.test eventsNames
        compoundArguments = {}
        undispatchedEvents = bindEventsList.concat []
        eventHandler = () ->
          eventData = _.last arguments
          compoundArguments[eventData.name] = arguments
          if _.contains undispatchedEvents, eventData.name
            undispatchedEvents = _.without undispatchedEvents, eventData.name
          if undispatchedEvents.length == 0
            undispatchedEvents = bindEventsList.concat []
            handler.call this, compoundArguments
      else
        eventHandler = handler

      self = @
      for eventName in bindEventsList
        do (eventName) ->
          self.create(eventName).bind eventHandler, context, options

      @create(bindEventsList[0])

    
    ####  Events::unbind(name, handler)
    #
    # Отвязывает обработчка от события
    #
    unbind: (name, handler) ->
      if @list[name]
        @list[name].unbind(handler)

    
    ####  Events::trigger(name, [args])
    #
    # Вызывает исполнение обработчиков событий, сохраняет переданные данные, если такого событие не было, то оно создается и в нем сохраняются эти данные
    #
    trigger: (name, args) ->
      @create(name).dispatch(args)

  #### Базовая шина событий
  #
  # представляет собой интерфейс модуля 
  #
  new Events("root")