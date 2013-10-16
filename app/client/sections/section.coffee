define [
  "events"
  "config"
  "loader"
  "widgets"
  "utils/widgetsData"
  "underscore"
  "clicks/forms"
  "dom"
], (events, config, loader, widgets, widgetsData, _, forms, dom) ->
  Section = () ->
    @name
    @params = {}
    @element

    @getSectionHtml = () ->
      unless @sectionHtml
        @sectionHtml = if @element? and @element.childNodes? then Array.prototype.slice.call @element.childNodes else []
      @sectionHtml

    @

  Section:: =
    turnOn: () ->
      @turnOnWidgets()
      @insertIntoDOM()
      @onInsert()

    turnOff: () ->
      @turnOffWidgets()
      @removeFromDOM()
      @onRemove()

    removeFromDOM: () ->
      for element in @getSectionHtml()
        element.parentNode.removeChild element if element.parentNode?

    insertIntoDOM: () ->
      return unless @params.target
      switch @params.target
        when "icon"
          return unless @element.href
          try
            newFavicon = document.createElement("link")
            newFavicon.setAttribute "type", "image/ico"
            newFavicon.setAttribute "rel", "shortcut icon"
            newFavicon.setAttribute "href", @element.href
            _.each dom('link[rel="shortcut icon"]'), (element) ->
              element.parentNode.removeChild element
            dom('head')[0].appendChild newFavicon
        else
          container = dom(@params.target)[0]
          return unless container?
          # говорим контейнеру, мол, теперь внутри вот такая-то секция.
          container.setAttribute config.sectionSelectorAttributeName, "#{@name}: #{JSON.stringify @params}"
          for element in @getSectionHtml()
            container.appendChild element

    turnOnWidgets: () ->
      loader.search @getSectionHtml(), (widgetsList) =>
        # удобно, но пока кажется избыточным такой notify
        #notifyAll "turnedOn", "-widgets", widgetsList
        on

    turnOffWidgets: () ->
      for data in widgetsData @getSectionHtml()
        widgets.get(data.name, data.element)?.sleepDown()

    onInsert: () ->
      postfix = "inserted"
      @notifyAll postfix
      @processNamespaces postfix

    onRemove: () ->
      postfix = "removed"
      @notifyAll postfix
      @processNamespaces postfix

    processNamespaces: (postfix) ->
      return if not @params.ns?

      @params.ns = [@params.ns] if _.isString @params.ns
      @notifyAll(postfix, "-#{type}") for type in @params.ns

    notifyAll: (postfix, suffix, params) ->
      return unless postfix
      triggerParams = [@]
      triggerParams.push params if params?
      events.trigger "section#{suffix}:#{postfix}", triggerParams

  Section
