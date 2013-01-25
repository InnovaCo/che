#### *module* sectionsHistory
#
# Модуль для поддержки истории переходов между страниц при помощи data-reload-sections
# 


define [
  'events', 
  'history',
  'widgets',
  'loader',
  'dom', 
  'ajax',
  'utils/storage',
  'utils/destroyer',
  'utils/widgetsData'], (events, history, widgets, loader, dom, ajax, storage, destroyer, widgetsData) ->
  ### 
  data:
    <selector>: <plainHTML>
  ###

  #### transitions
  #
  # Менеджер переходов, создает, либо достает уже ранее созданные переходы
  # 

  transitions =
    last: null
    current: null
    create: (state) ->
      state = state or {index: 0}
      if @last? and state.index <= @last.index
        transition = @go state.index
        transition.update state
        return transition
      else
        isNewState = (history.state or {}).url isnt state.url

        method = if isNewState then "pushState" else "replaceState"
        history[method] state, state.title, state.url
        @last = new Transition state, @last
        return @last

    go: (index) ->
      if not @current
        return @create()

      return @current if index is @current?.index
      direction = if @current.index < index then "next" else "prev"
      return @current[direction](index)


  #### Transition(@data)
  #
  # Конструктор переходов, переходы образуют между собой двусторонний связанный список
  # 
  Transition = (@state, last) ->
    @index = @state.index = @state.index or (last?.index + 1) or 0

    if last?
      @prev_transition = last
      last.next_transition = @

    if @state.widgets?
      @_invoker = new Invoker @state.widgets
      @invoke()

    return @

  Transition:: =
  
    #### Transition::update(data)
    #
    # Обновляет данные секций для перехода. Обновление происходит только если данные отличаются от текущих
    #
    update: (state) ->
      isStateTheSame = no
      if @state.url is state.url
        for selector, html of state.widgets
          isStateTheSame = @state.widgets[selector] is state.widgets[selector]
          if not isStateTheSame
            break
      else
        return

      if not isStateTheSame
        state.index = @index
        @state = state
        if @_invoker? and @state.widgets?
          @_invoker.update @state.widgets
        else if @state.widgets?
          @_invoker = new Invoker @state.widgets

        @invoke()



    #### Transition::next([to_transition])
    #
    # Переход вперед. Если переданы параметры перехода, то создается новый объект и ссылка на него записыватся в @next
    #
    next: (to_transition) ->
      if to_transition is @index
        return @
      
      if @next_transition?
        @next_transition.invoke()
        if to_transition? then @next_transition.next(to_transition)

    #### Transition::prev([to_transition])
    #
    # Переход назад
    #
    prev: (to_transition) ->
      if to_transition is @index
        return @

      if @prev_transition?
        @undo()
        if to_transition? then @prev_transition.prev(to_transition)


    #### Transition::undo()
    #
    # Отмена действий при переходе
    #
    undo: () ->
      transitions.current = @prev_transition
      @_invoker?.undo()
      events.trigger "sectionsTransition:undone", @

    #### Transition::invoke()
    #
    # Применение действий перехода
    #
    invoke: () ->
      transitions.current = @
      @_invoker?.run()
      events.trigger "sectionsTransition:invoked", @

  #### Invoker(@reloadSections)
  #
  # Конструктор объекта действий при переходе, содежит в себе данные для переходов в обе стороны, используется в transitions
  # 
  Invoker = (@reloadSections) ->
    @_back = null
    @_forward = null
    @_is_applied = no
    @_is_sections_updated = no

  Invoker:: =

    #### Invoker::update()
    #
    # Обновление данных о секциях
    #
    update: (sections) ->
      @reloadSections = sections
      @_is_sections_updated = no

    #### Invoker::run()
    #
    # Применение действий перехода, а также генерация данных для обратного перехода
    #
    run: ->
      if @_is_applied
        @undo()

      if not @_is_sections_updated or not @_forward or not @_back
        @_back = {}
        @_forward = {}
        for selector, html of @reloadSections
          @_back[selector] = dom selector
          @_forward[selector] = dom html
        @_is_sections_updated = yes

      @_insertSections @_forward, @_back
      @_is_applied = yes

    #### Invoker::undo()
    #
    # Отмена действий перехода
    #
    undo: ->
      return false if not @_forward and not @_back or @_is_applied isnt true
      @_insertSections @_back, @_forward
      @_is_applied = no


    #### Invoker::_insertSections(forward, back)
    #
    # Вставка секций forward вместо секций back
    #
    _insertSections: (forward, back, selectors) ->
      selectors = selectors or _.keys back
      return events.trigger "sections:inserted" if selectors.length is 0

      selector = selectors.shift()

      loader.search forward[selector], (widgetsList) =>

        for data in widgetsData back[selector]
          widgets.get(data.name, data.element)?.turnOff()

        back[selector].replaceWith forward[selector]
        return @_insertSections forward, back, selectors


  #----

  #### transitions.current
  #
  # ссылка на текущий переход
  #
  transitions.current = transitions.create()


  sectionsRequest = null

  #### loadSections
  #
  # Загрузка секций с сервера, обрабатывается только самый последний запрос
  #
  loadSections = (url, method, index) ->
    sectionsRequest?.abort()
    sectionsRequest = ajax.get
      url: url,
      method: method

    sectionsRequest.success (request, state) ->
      state.url = url
      state.index = index
      state.method = method
      events.trigger "sections:loaded", state


  #### Обработка "sections:loaded"
  #
  # Секции сохраняются в localStorage, и далее отдаются на инициализацию
  #
  events.bind "sections:loaded", (state) ->
    storage.save "sectionsHistory", state.url, state
    transitions.create state


  #### Обработка pageTransition:init
  #
  # Проверяется, есть ли такие секции уже в localStorage, если есть, то используем их и параллельно смотрим на сервере
  #
  events.bind "pageTransition:init", (url, method) ->
    state = storage.get "sectionsHistory", url
    if state?
      delete state.index
      transitions.create state

    loadSections url, method


  #### Обработка history:popState
  #
  # Переходит до нужного состояния и проверяет обновления на сервере
  #
  events.bind "history:popState", (state) ->
    if state?
      transitions.go state.index
      loadSections state.url, state.method, state.index
    # here ask server for updated sections (history case)

  _transitions: transitions
  _transition: Transition
  _invoker: Invoker