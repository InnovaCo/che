#### *module* sectionsHistory
#
# Модуль для поддержки истории переходов между страниц при помощи data-reload-sections
# 

# требует модули 'events', 'widgets', 'dom'

define [
  'events', 
  'history',
  'widgets', 
  'dom', 
  'ajax',
  'utils/params',
  'utils/storage',
  'utils/destroyer',
  'utils/widgetsData'], (events, history, widgets, dom, ajax, params, storage, destroyer, widgetsData) ->
  ### 
  data:
    <selector>: <plainHTML>
  ###

  #### Transition(@data)
  #
  # Конструктор переходов, переходы образуют между собой двусторонний связанный список
  # 
  Transition = (data) ->
    data = data or {index: 0}
    if Transition.last? and data.index <= Transition.last.index
      direction = null
      if data.index is Transition.current.index
        Transition.current.update data

      else if Transition.current.index < data.index
        direction = "next"
      else if data.index < Transition.current.index
        direction = "prev"

      if direction?
        transition = Transition.current[direction]?(data.index)
        transition.update data

      return Transition.current
    else
      @data = data
      @index = @data.index = @data.index or (Transition.last?.index + 1) or 0

      @prev_transition = Transition.last
      if Transition.last?
        Transition.last.next_transition = @

      Transition.last = @

      if @data.widgets?
        @_invoker = new Invoker @data.widgets
        @invoke()

      return @

  Transition.first = null
  Transition.last = null
  Transition.current = null

  Transition:: =
  
    #### Transition::update(data)
    #
    # Обновляет данные секций для перехода. Обновление происходит только если данные отличаются от текущих
    #
    update: (data) ->
      isDataTheSame = no
      if @data.url is data.url
        for selector, html of data.widgets
          isDataTheSame = @data.widgets[selector] is data.widgets[selector]
          if not isDataTheSame
            break

      if isDataTheSame = no
        data.index = @index
        @data = data
        if @_invoker? and @data.widgets?
          @_invoker.update @data.widgets
        else if @data.widgets?
          @_invoker = new Invoker @data.widgets

        if Transition.current is @
          @invoke()
      #check if data is not the same else return


    #### Transition.prototype.next([to_transition])
    #
    # Переход вперед. Если переданы параметры перехода, то создается новый объект и ссылка на него записыватся в @next
    #
    next: (to_transition) ->
      if to_transition is @index
        return @
      
      if @next?
        @next_transition.invoke()
        if to_transition? then @next_transition.next(to_transition)

    #### Transition.prototype.prev([to_transition])
    #
    # Переход назад
    #
    prev: (to_transition) ->
      if to_transition is @index
        return @

      if @prev?
        @undo()
        if to_transition? then @prev_transition.prev(to_transition)


    #### Transition.prototype.undo()
    #
    # Отмена действий при переходе
    #
    undo: () ->
      Transition.current = @prev_transition
      @_invoker?.undo()
      events.trigger "sectionsTransition:undone"

    #### Transition.prototype.invoke()
    #
    # Применение действий перехода
    #
    invoke: () ->
      Transition.current = @
      @_invoker?.run()
      events.trigger "sectionsTransition:invoked"

  #### Invoker(@reloadSections)
  #
  # Конструктор объекта действий при переходе, содежит в себе данные для переходов в обе стороны, используется в Transitions
  # 
  Invoker = (@reloadSections) ->
    @_back = null
    @_forward = null
    @_is_appied = no
    @_is_sections_updated = no

  Invoker:: =

    update: (sections) ->
      @reloadSections = sections
      @_is_sections_updated = no
      # @_back = null
      # @_forward = null

    #### Invoker.prototype.run()
    #
    # Применение действий перехода, а также генерация данных для обратного перехода
    #
    run: ->
      if @_is_appied
        @undo()

      if not @_is_sections_updated or not @_forward or not @_back
        @_back = {}
        @_forward = {}
        for selector, html of @reloadSections
          @_reloadSectionInit selector, html
        @_is_sections_updated = yes

      @_insertSections @_forward, @_back
      @_is_appied = yes

    #### Invoker.prototype.undo()
    #
    # Отмена действий перехода
    #
    undo: ->
      return false if not @_forward and not @_back or @_is_appied isnt true
      @_insertSections @_back, @_forward
      @_is_appied = no


    #### Invoker.prototype._reloadSectionInit(selector, html)
    #
    # Инициализация секции для вставки в DOM (создаются данные перехода для секции, а также данные для отмены этого действия)
    #
    _reloadSectionInit: (selector, html) ->
      prevElement = dom selector

      @_back[selector] =
        widgets: []
        element: prevElement
        widgetsInitData: widgetsData prevElement

      nextElement = dom html

      @_forward[selector] = 
        widgets: []
        element: nextElement
        widgetsInitData: widgetsData nextElement

    #### Invoker.prototype._insertSections()
    #
    # вставка секций из forward и отключение секций из back
    #
    _insertSections: (forward, back) ->
      self = @
      _.each forward, (data, selector) ->
        self._initWidgets widgetsData(data.element), (widgetsList) ->
          forward[selector].widgets = widgetsList
          replaceableElement = back[selector].element

          if back[selector].widgets
            for widget in back[selector].widgets
              widget.turnOff()

          else if back[selector].widgetsInitData
            for data in back[selector].widgetsInitData
              widgets.get(data.name, data.element)?.turnOff()

          replaceableElement.replaceWith data.element


    #### Invoker.prototype._initWidgets(widgetsDataList, ready)
    #
    # инициализация виджетов
    #
    _initWidgets: (widgetsDataList, ready) ->
      widgetsCount = _.keys(widgetsDataList).length
      list = []
      if widgetsCount is 0
        return ready(list)
      for data in widgetsDataList
        widgets.create data.name, data.element, (widget) ->
          list.push widget
          widget.turnOn()
          widgetsCount -= 1
          if widgetsCount is 0
            ready(list)

  sectionsRequest = null
  loadSections = (url, index) ->
    sectionsRequest?.abort()
    sectionsRequest = ajax.get
      url: url
    sectionsRequest.success (request, state) ->
      state.url = url
      state.index = index
      events.trigger "sections:loaded", state

  initSections = (state) ->
    history_state = history.state or {}
    if history_state.url isnt state.url
      history.pushState state, state.title, state.url
    new Transition state

  events.bind "pageTransition:init", (url, data) ->
    # here ask for sections in cache and then server for new sections
    splitted_url = url.split "?"
    GETUrl = "#{splitted_url[0]}?#{splitted_url[1] or ""}#{params data}"

    state = storage.get "sectionsHistory", GETUrl
    lastStateIndex = Transition.last.index + 1
    if state?
      state.index = lastStateIndex
      initSections state

    loadSections GETUrl, lastStateIndex
        


  #### Transition.current
  #
  # ссылка на текущий переход
  #
  Transition.current = new Transition

  events.bind "history:popState", (state) ->
    new Transition state

    if state?
      loadSections state.url, state.index
    # here ask server for updated sections (history case)

  events.bind "sections:loaded", (state) ->
    save_state = _.clone state
    delete save_state.index
    storage.save "sectionsHistory", state.url, save_state
    initSections state

  _getCurrentTransition: ->
    Transition.current
  _getFirstTransition: ->
    firstTransition
  _transition: Transition
  _invoker: Invoker