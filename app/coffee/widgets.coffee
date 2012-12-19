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

  bindWidgetDomEvents = (eventsList, widget) ->
    elem = dom widget.element

    _.each eventsList, (handler, eventDescr) ->
      splittedDescr = eventDescr.split(eventSplitter)
      name = splittedDescr[1]
      selector = splittedDescr[2]
      handler = if _.isString handler then widget[handler] else handler
      eventsList[eventDescr] = handler
      elem.on selector, name, handler

  unbindWidgetDomEvents = (eventsData, widget) ->
    elem = dom widget.element

    _.each eventsData, (handler, eventDescr) ->
      splittedDescr = eventDescr.split eventSplitter
      name = splittedDescr[1]
      selector = splittedDescr[2]
      elem.off selector, name, handler

  bindWidgetModuleEvents = (eventsList, widget) ->
    _.each eventsList, (handler, name) ->
      handler = if _.isString handler then widget[handler] else handler
      events.bind name, handler, widget
      eventsList[name] = handler

  unbindWidgetModuleEvents = (eventsList) ->
    _.each eventsList, (handler, name) ->
      events.unbind name, handler
      

  Widget = (@name, @element, _widget) ->
    console.log element
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
    turnOn: ->
      if @_isOn
        return
      console.log "turn on"
      bindWidgetDomEvents @domEvents, @
      bindWidgetModuleEvents @moduleEvents, @
      @_isOn = yes
      @

    turnOff: ->
      if not @_isOn
        return
      
      console.log "turn off"
      unbindWidgetDomEvents @domEvents, @
      unbindWidgetModuleEvents @moduleEvents, @
      @_isOn = no
      @

    destroy: ->
      @turnOff()
      @element.removeAttribute "data-widget-" + @name + "-id"
      delete widgetsInstances[@id]
      destroyer(@)


    # @_widget.init.apply(this, [element])
  widgets =
    _instances: widgetsInstances
    _constructor: Widget
    create: (name, element, ready) ->
      require [name], (widget) ->
        ready new Widget(name, element, widget)

