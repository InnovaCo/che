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

  Section:: =
    init: () ->
      if @element? and @element.childNodes?
        @sectionHtml = Array.prototype.slice.call @element.childNodes
        # навешиваем события на submit формы внутри секции
        forms.processForms @element
      else
        @sectionHtml = []


    removeFromDOM: () ->
      @init() unless @sectionHtml?
      for element in @sectionHtml
        element.parentNode.removeChild element if element.parentNode?

      @onRemove()

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
            oldFavicon = dom('link[rel="shortcut icon"]')[0]
            oldFavicon.parentNode.replaceChild newFavicon, oldFavicon if oldFavicon?
        else
          container = dom(@params.target)[0]
          return unless container?
          @init() unless @sectionHtml?

          # говорим контейнеру, мол, теперь внутри вот такая-то секция.
          container.setAttribute config.sectionSelectorAttributeName, "#{@name}: #{JSON.stringify @params}"
          for element in @sectionHtml
            container.appendChild element

      @onInsert()

    turnOnWidgets: () ->
      @init() unless @sectionHtml?
      loader.search @sectionHtml, (widgetsList) =>
        # удобно, но пока кажется избыточным такой notify
        #notifyAll "turnedOn", "-widgets", widgetsList
        on

    turnOffWidgets: () ->
      for data in widgetsData @element
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
      #console.log suffix, postfix, triggerParams
      events.trigger "section#{suffix}:#{postfix}", triggerParams

  Section
