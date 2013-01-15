#### *module* widgets
#
# Инициализирует виджеты на DOM-элементах, хранит список инстансов
#

define ["events", "dom", "utils/destroyer", "config", "utils/guid"], (events, dom, destroyer, config, guid)->
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
    @_attr_name = "data-#{@name}-id".replace("/", "-")

    id = @element.getAttribute @_attr_name
    return widgetsInstances[id] if id and widgetsInstances[id]

    _.extend @, _widget
    @id = guid()
    @init?(@element)
    @turnOn()
    @isInitialized = yes
    
    

    @element.setAttribute @_attr_name, @id
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
      @element.removeAttribute @_attr_name
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

    #### widgets.get(name, element)
    #
    # Возвращает уже ранее созданный экземпляр виджета для конкретного элемента

    get: (name, element) ->

      id = element.getAttribute "data-#{name}-id".replace "/", "-"
      return @_instances[id]

    #### widgets.create(name, element, ready)
    #
    # Подгружает необходимый модуль (по имени) и инициализирует виджет

    create: (name, element, ready) ->
      console.log "widget", name, element
      if not (///^http///).test name
        name = config.baseWidgetsPath + name
      require [name], (widget) ->
        instance = new Widget(name, element, widget)
        if _.isFunction(ready) then ready instance

