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
  'config',
  'utils/storage',
  'utils/destroyer',
  'utils/widgetsData',
  'underscore'], (events, history, widgets, loader, dom, ajax, config, storage, destroyer, widgetsData, _) ->
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

    if @state.sections?
      @_invoker = new Invoker @state.sections
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
        isStateTheSame = @state.sections is state.sections
      else
        return

      if not isStateTheSame
        state.index = @index
        @state = state
        if @_invoker? and @state.sections?
          @_invoker.update @state.sections
        else if @state.sections?
          @_invoker = new Invoker @state.sections

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
    console.log "INIT INVOKER", @reloadSections
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
        console.log "RUN", @

        reloadSectionsHtml = dom @reloadSections
        currentTitle = dom('title')[0]
        nextTitle = reloadSectionsHtml.find('title')[0]

        @_back = {}
        @_forward = {}
        if currentTitle
          @_back.title = currentTitle.childNodes[0]

        if nextTitle
          @_forward.title = nextTitle.childNodes[0]

        for element in reloadSectionsHtml.get()
          nodeName = element.nodeName.toLowerCase()
          if nodeName is config.sectionTagName
            selector = element.getAttribute "data-#{config.sectionSelectorAttributeName}"
          else if nodeName is 'title'
            selector = nodeName
          else
            continue

          @_back[selector] = Array.prototype.slice.call dom(selector)[0]?.childNodes
          @_forward[selector] = Array.prototype.slice.call element.childNodes

          console.log @_back, @_forward

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

        container = dom(selector)[0]

        

        for element in back[selector]
          console.log "WIDGETS DATA", element, widgetsData element
          if element.parentNode?
            element.parentNode.removeChild element

          for data in widgetsData element
            console.log "OLD WIDGETS", data
            widgets.get(data.name, data.element)?.turnOff()

        for element in forward[selector]
          container.appendChild element

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

    sectionsRequest.success (request, sections) ->
      state.url = ""
      state.index = index
      state.method = method
      state.sections = sections

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