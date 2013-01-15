#### *module* sectionsHistory
#
# Модуль для поддержки истории переходов между страниц при помощи data-reload-sections
# 

# требует модули 'events', 'widgets', 'dom'

define [
  'events', 
  'widgets', 
  'dom', 
  'utils/destroyer',
  'utils/widgetsData'], (events, widgets, dom, destroyer, widgetsData) ->
  ### 
  data:
    <selector>: <plainHTML>
  ###

  #### Transition(@data, previousTransition)
  #
  # Конструктор переходов, переходы образуют между собой двусторонний связанный список
  # 

  depthTreshold = 10


  Transition = (data, previousTransition) ->
    @data = data or {}
    if previousTransition?
      @prev = previousTransition
      previousTransition.next = @

    if Transition.last? and @data.index <= Transition.last.index
      direction = ""
      # if @data.index is Transition.last.index

      if Transition.current.index < @data.index
        direction = "next"
      else if @data.index < Transition.current.index
        direction = "prev" 

      Transition.current = Transition.current[direction]?(@data.index) or Transition.current
      return Transition.current

    @depth = if previousTransition then previousTransition.depth + 1 else 0
    @index = @data.index

    @prev_transition = Transition.last
    if Transition.last?
      Transition.last.next_transition = @

    Transition.last = @

    Transition.current = @
    if @data?
      @_invoker = new Invoker @data.widgets
      @invoke()

  Transition.first = null
  Transition.last = null
  Transition.current = null

  Transition:: =
    #### Transition.prototype.next([data])
    #
    # Переход вперед. Если переданы параметры перехода, то создается новый объект и ссылка на него записыватся в @next
    #
    next: (to_transition) ->
      if to_transition is @index
        return @
      
      if @next?
        @next_transition.invoke()
        Transition.current = @next_transition
        if to_transition? then @next_transition.next(to_transition)

    #### Transition.prototype.prev()
    #
    # Переход назад
    #
    prev: (to_transition) ->
      if to_transition is @index
        return @

      if @prev?
        @undo()
        Transition.current = @prev_transition
        if to_transition? then @prev_transition.prev(to_transition)


    #### Transition.prototype.undo()
    #
    # Отмена действий при переходе
    #
    undo: () ->
      @_invoker?.undo()

    #### Transition.prototype.invoke()
    #
    # Применение действий перехода
    #
    invoke: () ->
      @_invoker?.run()
      

  #### Invoker(@reloadSections)
  #
  # Конструктор объекта действий при переходе, содежит в себе данные для переходов в обе стороны, используется в Transitions
  # 
  Invoker = (@reloadSections) ->
    @_back = null
    @_forward = null

  Invoker:: =

    #### Invoker.prototype.run()
    #
    # Применение действий перехода, а также генерация данных для обратного перехода
    #
    run: ->
      if not @_forward and not @_back
        self = @
        @_back = {}
        @_forward = {}
        _.each @reloadSections, (html, selector) ->
          self._reloadSectionInit selector, html

      @_insertSections(@_forward, @_back)



    #### Invoker.prototype.undo()
    #
    # Отмена действий перехода
    #
    undo: ->
      return false if not @_forward and not @_back
      @_insertSections(@_back, @_forward)


    #### Invoker.prototype._reloadSectionInit(selector, html)
    #
    # Инициализация секции для вставки в DOM (создаются данные перехода для секции, а также данные для отмены этого действия)
    #
    _reloadSectionInit: (selector, html) ->
      prevElement = dom selector

      @_back[selector] =
        widgets: []
        element: prevElement
        # widgetsInitData: widgetsData prevElement

      nextElement = dom html

      @_forward[selector] = 
        widgets: []
        element: nextElement
        # widgetsInitData: widgetsData nextElement


    #### Invoker.prototype._insertSections()
    #
    # вставка секций из forward и отключение секций из back
    #
    _insertSections: (forward, back) ->
      self = @
      _.each forward, (data, selector) ->
        self._initWidgets [], (widgetsList) -> # widgetsData(data.element), (widgetsList) ->
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

  #### Transition.current
  #
  # ссылка на текущий переход
  #
  Transition.current = new Transition

  events.bind "history:pushState", (state) ->
    new Transition state

  events.bind "history:popState", (state) ->
    console.log state, "pop state Loaded"
    new Transition state

  _getCurrentTransition: ->
    Transition.current
  _getFirstTransition: ->
    firstTransition
  _transition: Transition
  _invoker: Invoker