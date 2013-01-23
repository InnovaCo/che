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


  #### widgets
  #
  # Менеджер виджетов, следит за тем, чтобы лишнего не было создано, а также может удалять уже не нужные экземпляры виджетов
  #

  widgets = 
    _instances: {}
    _id_attr: (name) ->
      return "data-#{name}-id".replace "/", "-"
    remove: (widget) ->
      widget.element.removeAttribute @_id_attr widget.name
      delete @_instances[widget.id]
      destroyer widget

    get: (name, element) ->
      id_attr = @_id_attr name
      return @_instances[element.getAttribute id_attr]

    add: (name, element, _widget) ->
      prevInstance = @get name, element
      if prevInstance?
        # do some things with existing instance, if need so
        return prevInstance

      instance = new Widget name, element, _widget
      instance.element.setAttribute @_id_attr(name), instance.id
      @_instances[instance.id] = instance

      instance
  

  #### Widget(@name, @element, _widget)
  #
  # Конструктор виджетов, инициализирует виджет на DOM-элементе только один раз, в следующие разы возвращает уже созданные экземпляры
  #

  Widget = (@name, @element, _widget) ->
    _.extend @, _widget
    @id = guid()
    @init?(@element)
    @turnOn()
    @isInitialized = yes

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
      widgets.remove @



    #### widgets._manager
    #
    # Ссылка на менеджер виджетов

    _manager: widgets

    #### widgets._constructor
    #
    # Ссылка на конструктор виджетов

    _constructor: Widget

    #### widgets.get(name, element)
    #
    # Возвращает уже ранее созданный экземпляр виджета для конкретного элемента

    get: (name, element) ->
      name = config.baseWidgetsPath + name
      return widgets.get name, element

    #### widgets.create(name, element, ready)
    #
    # Подгружает необходимый модуль (по имени) и инициализирует виджет

    create: (name, element, ready) ->
      if not (///^http///).test name
        name = config.baseWidgetsPath + name
      require [name], (widget) ->
        instance = widgets.add name, element, widget
        console.log "widget", name, element, instance
        ready?(instance)

