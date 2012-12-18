define ["events", "dom", "utils/destroyer"], (events, dom, destroyer)->
  widgetsInstances = {}
  eventSplitter = /^(\S+)\s*(.*)$/

  # sampleWidget =
  #   domEvents: 
  #   moduleEvents:
  #   init: ->
  #   destroy: ->
  #   turnOn: ->
  #   turnOff: ->

  bindWidgetDomEvents: (eventsList, widget) ->
    elem = dom widget.element

    _.each eventsList, (eventDescr, handler) ->
      splittedDescr = eventDescr.split(eventSplitter)
      name = splittedDescr[1]
      selector = splittedDescr[2]
      handler = if _.isString handler then widget[handler] else handler
      eventsList[eventDescr] = handler
      elem.on name, selector, handler

  unbindWidgetDomEvents: (eventsData, widget) ->
    _.each eventsData, (eventDescr, handler) ->
      splittedDescr = eventDescr.split eventSplitter
      name = splittedDescr[1]
      selector = splittedDescr[2]
      elem.off name, selector, handler

  bindWidgetModuleEvents: (eventsList, widget) ->
    _.each eventsList, (handler, name) ->
      handler = if _.isString handler then widget[handler] else handler
      events.bind name, handler, widget
      eventsList[name] = handler

  unbindWidgetModuleEvents: (eventsList) ->
    _.each eventsList, (handler, name) ->
      events.unbind name, handler
      

  Widget = (@name, element, _widget) ->
    id = @element.getAttribute "data-widget-" + @name + "-id"
    return widgetsInstances[id] if id

    _.extend @, _widget
    @id = _.uniqueId "widget_"
    @element = element
    @init()
    @isInitialized = yes
    @element.getAttribute "data-widget-" + @name + "-id", @id
    widgetsInstances[@id] = @

  Widget:: =
    init: ->
      if @isInitialized
        return @

      @turnOn()
      @

    turnOn: ->
      if @_isOn
        return

      bindWidgetDomEvents @domEvents, @
      bindWidgetModuleEvents @moduleEvents, @
      @_isOn = yes
      @

    turnOff: ->
      if not @_isOn
        return
        
      unbindWidgetDomEvents @domEvents
      unbindWidgetModuleEvents @moduleEvents
      @_isOn = no
      @

    destroy: ->
      @turnOff()
      delete widgetsInstances[@id]
      @_widget.destroy?()
      destroyer(@)


    # @_widget.init.apply(this, [element])
  widgets =
    create: (widgetData) ->
      require [widgetData.name], (widget) ->
        new Widget(widgetData.name, widgetData.element, widget)
