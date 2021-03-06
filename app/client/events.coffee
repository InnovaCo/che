#### *module* events
#
# Реализация шины событий можно привязывать, отвязывать,
# либо обрабатывать событие только один раз, кроме того есть
# возможность создавать другие шины событий, что полезно
# для упрощения логики внутри модулей, и при этом не сыплется
# лишнего в глобальную шину событий.
#

define ['underscore'],  (_) ->


  #### Oops(name)
  #
  # Конструктор события, назначает имя, инициализирует
  # спискок обработчиков пустым объектом
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
    # Вызывает очередного обработчика
    #
    _handlerCaller: (handler, args) ->
      if handler.contexts.length
        for context in handler.contexts
          handler.apply context, args
      else
        handler.apply null, args


    ####  Oops.prototype._nextHandlerCall
    #
    # Достает очередного обработчика события и передает его для вызова
    #
    _nextHandlerCall: (args) ->
      handlerId = @_handlersCallOrder.shift()
      if handlerId
        handler = @_handlers[handlerId]
        if handler.options.isSync
          @_handlerCaller handler, args
        else
          _.delay(
            => @_handlerCaller handler, args
            1
          )
        @_nextHandlerCall(args)


    ####  Oops.prototype.dispatch(args)
    #
    # Запускает исполнение обработчиков события
    #
    dispatch: (args) ->
      args = if _.isArray(args) then args else [args]
      @_handlersCallOrder = _.keys(@_handlers).sort()
      args.push this._data()
      @_lastArgs = args

      @_nextHandlerCall args
      @


    ####  Oops.prototype.bind(handler, context, [options])
    #
    # Привязывает обработчик к событию
    #
    bind: (handler, context, options) ->
      handler.id = handler.id or +_.uniqueId()
      handler.contexts = handler.contexts or []
      if context? and not _.find(handler.contexts, (value)-> value is context)
        handler.contexts.push(context)

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
    unbind: (handler, context) ->
      id = handler.id
      if id and @_handlers[id]
        if context?
          handler.contexts = _.filter handler.contexts, (deleteContext) -> deleteContext isnt context
          delete @_handlers[id] if not handler.contexts.length
        else
          delete @_handlers[id]
      @

  window.evnts = []

  ####  Events
  #
  # Конструктор для шин событий, может создавать новые шины,
  # которые могут наследовать родительские события
  #
  Events = (@_id) ->
    ####  events.list
    #
    # Список событий
    #
    @list = {}
    @

  Events:: =

    ####  Events::sprout([name])
    #
    # Отпочковывает объект событий, если указано имя [name],
    # то сохраняет ссылку на дочений объект в поле родительского
    # по указанному имени.
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
      @list[name] = @list[name] or new Oops name

    createList: (name, pureOnly) ->
      nameInNS = name.split "@"
      namePure = nameInNS[0]
      evts = []
      evts[namePure] = @create namePure
      if !pureOnly and nameInNS.length > 1
        for index in [1..(nameInNS.length-1)]
          nameWithNS = "#{namePure}@#{nameInNS[index]}"
          evts[nameWithNS] = @create nameWithNS
      evts

    ####  Events::once(name, handler, [context], [options])
    #
    # Создает новое событие, либо отдает уже созданное
    # и привязывает обработчика, который сработает только один раз
    #
    once: (name, handler, context, options) ->
      @create(name).once(handler, context, options)


    ####  Events::bind(eventsNames, handler, [context], [options])
    #
    # Создает новое событие (может быть и несколько, если
    # в eventsNames указаны имена через запятую), либо отдает
    # уже созданное и привязывает обработчика
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

      for eventName in bindEventsList
        do (eventName) =>
          @create(eventName).bind(eventHandler, context, options)

      @create(bindEventsList[0])

    ####  Events::unbind(name, handler)
    #
    # Отвязывает обработчка от события
    #
    unbind: (name, handler, context) ->
      nameInNS = name.split "@"
      namePure = nameInNS[0]

      @list[namePure].unbind(handler, context) if @list[namePure]

      if nameInNS.length > 1
        for index in [1..(nameInNS.length-1)]
          nameWithNS = "#{namePure}@#{nameInNS[index]}"
          @list[nameWithNS].unbind(handler, context) if @list[nameWithNS]


    ####  Events::trigger(name, [args])
    #
    # Вызывает исполнение обработчиков событий, сохраняет переданные
    # данные, если такого событие не было, то оно создается
    # и в нем сохраняются эти данные
    #
    trigger: (name, args) ->
      #console.log "TRIGGER", name, args
      evt.dispatch(args) for evtName, evt of @createList(name)


  #### Глобальная шина событий
  #
  # представляет собой интерфейс модуля
  #
  new Events("root")