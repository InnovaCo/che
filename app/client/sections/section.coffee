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
  extensionRegex = /\.css$/

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
    turnOn: (before, after) ->
      @loadStyles =>
        before?()
        @turnOnWidgets()
        @insertIntoDOM()
        @onInsert()
        after?()

        # Из-за того что браузеры отменяют загрузку ресурсов после удаления DOM элементов, то после
        # смены секций мы возобновляем загрузку ресурсов за счет резолва html строки в DOM элемент.
        dom @getSectionHtml()

    loadStyles: (callback) ->
      depList = []
      headElement = dom('head')[0]
      hasExternalPlugin = require.specified "css"

      for element in dom(@getSectionHtml()).find("[#{config.widgetCssAttributeName}]").get()
        if element.getAttribute?
          cssPath = element.getAttribute config.widgetCssAttributeName
          cssPath = "#{cssPath.replace(extensionRegex, "")}.css" if cssPath?

          if not hasExternalPlugin
            linkNode = document.createElement "link"
            linkNode.rel = "stylesheet"
            linkNode.type = "text/css"
            linkNode.href = cssPath
            headElement.appendChild linkNode
          depList.push "css!#{cssPath}"

      if depList.length
        if hasExternalPlugin
          # Если загрузчик поддерживает обработчик завершения загрузки стилей, то чтоб стили 
          # точно успели применится делаем задержку в 100мс перед возобновлением пайплайна смены 
          # секций.
          require depList, -> setTimeout callback, 100
        else
          console.warn "External plugin for loading css is not found. Creating direct links..."
          callback?()
      else
        callback?()

    turnOff: ->
      @turnOffWidgets()
      @removeFromDOM()
      @onRemove()

    removeFromDOM: ->
      for element in @getSectionHtml()
        element.parentNode.removeChild element if element.parentNode?

    insertIntoDOM: ->
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
          # говорим контейнеру, мол, теперь внутри вот такая-то секция.
          container.setAttribute config.sectionSelectorAttributeName, "#{@name}: #{JSON.stringify @params}"
          for element in @getSectionHtml()
            container.appendChild element

    turnOnWidgets: ->
      loader.search @getSectionHtml()

    turnOffWidgets: ->
      for data in widgetsData @getSectionHtml()
        widgets.get(data.name, data.element)?.sleepDown()

    onInsert: ->
      postfix = "inserted"
      @notifyAll postfix
      @processNamespaces postfix

    onRemove: ->
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
