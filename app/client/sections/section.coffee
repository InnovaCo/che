define [
  "events"
  "config"
  "loader"
  "utils/widgetsData"
  "underscore"
  ], (events, config, loader, widgetsData, _) ->
  Section = () ->
    @name
    @params = {}
    @element

  Section:: =
    init: () ->
      @sectionHtml = Array.prototype.slice.call @element.childNodes
      # @processNamespaces "inited"

    removeFromDOM: () ->
      @init() unless @sectionHtml?
      for element in @sectionHtml
        element.parentNode.removeChild element

      @onRemove()

    insertIntoDOM: ( container ) ->
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
      for element in @element
        # if element.parentNode?
        #   element.parentNode.removeChild element
        for data in widgetsData element
          widgets.get(data.name, data.element)?.turnOff()

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
      console.log suffix, postfix, triggerParams
      events.trigger "section#{suffix}:#{postfix}", triggerParams

  Section