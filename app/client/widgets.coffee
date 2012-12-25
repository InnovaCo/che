#### *module* widgets
#
# Инициализирует виджеты на DOM-элементах, хранит список инстансов
#

define ["events", "dom", "utils/destroyer", "config"], (events, dom, destroyer, config)->
  widgetsInstances = {}
  eventSplitter = /^(\S+)\s*(.*)$/

  #### bindWidgetDomEvents(eventsList, widget)
  #
  # Привязывает обработчиков событий на корень DOM-элемента и делегирует им события

  bindWidgetDomEvents = (eventsList, widget) ->
    elem = dom widget.element

    _.each eventsList, (handler, eventDescr) ->
      splittedDescr = eventDescr.split(eventSplitter)
      name = splittedDescr[1]
      selector = splittedDescr[2]
      handler = if _.isString handler then widget[handler] else handler
      eventsList[eventDescr] = handler
      elem.on selector, name, handler


  #### unbindWidgetDomEvents(eventsData, widget)
  #
  # Отвязывает обработчиков с корня

  unbindWidgetDomEvents = (eventsData, widget) ->
    elem = dom widget.element
    _.each eventsData, (handler, eventDescr) ->
      splittedDescr = eventDescr.split eventSplitter
      name = splittedDescr[1]
      selector = splittedDescr[2]
      elem.off selector, name, handler


  #### bindWidgetModuleEvents(eventsList, widget)
  #
  # Привязывает обработчиков событий приложения

  bindWidgetModuleEvents = (eventsList, widget) ->
    _.each eventsList, (handler, name) ->
      handler = if _.isString handler then widget[handler] else handler
      events.bind name, handler, widget
      eventsList[name] = handler


    #### unbindWidgetModuleEvents(eventsList)
    #
    # Отвязывает обработчиков событий приложения

  unbindWidgetModuleEvents = (eventsList) ->
    _.each eventsList, (handler, name) ->
      events.unbind name, handler
  

  #### Widget(@name, @element, _widget)
  #
  # Конструктор виджетов, инициализирует виджет на DOM-элементе только один раз, в следующие разы возвращает уже созданные экземпляры

  Widget = (@name, @element, _widget) ->
    id = @element.getAttribute "data-widget-" + @name + "-id"
    return widgetsInstances[id] if id and widgetsInstances[id]

    _.extend @, _widget
    @id = _.uniqueId "widget_"
    @init?(@element)
    @turnOn()
    @isInitialized = yes
    @element.setAttribute "data-widget-" + @name + "-id", @id
    widgetsInstances[@id] = @

  Widget:: =

    #### Widget.prototype.turnOn()
    #
    # Привязывает обработчиков событий

    turnOn: ->
      if @_isOn
        return
      bindWidgetDomEvents @domEvents, @
      bindWidgetModuleEvents @moduleEvents, @
      @_isOn = yes
      @

    #### Widget.prototype.turnOff()
    #
    # Отвязывает обработчиков событий

    turnOff: ->
      if not @_isOn
        return
      unbindWidgetDomEvents @domEvents, @
      unbindWidgetModuleEvents @moduleEvents, @
      @_isOn = no
      @

    #### Widget.prototype.destroy()
    #
    # Отвязывает обработчиков событий и очищает экземпляр виджета

    destroy: ->
      @turnOff()
      @element.removeAttribute "data-widget-" + @name + "-id"
      delete widgetsInstances[@id]
      destroyer(@)

  #### widgets
  #
  # интерфейс модуля
  widgets =

    #### widgets._instances
    #
    # Ссылка на список экземпляров виджетов

    _instances: widgetsInstances

    #### widgets._constructor
    #
    # Ссылка на конструктор виджетов

    _constructor: Widget

    #### widgets.create(name, element, ready)
    #
    # Подгружает необходимый модуль (по имени) и инициализирует виджет

    create: (name, element, ready) ->
      if not (///^http///).test name
        name = config.baseWidgetsPath + name
      require [name], (widget) ->
        ready new Widget(name, element, widget)

