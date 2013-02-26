define [
  "sections/asyncQueue",
  "dom",
  "events",
  "loader",
  "config",
  "utils/widgetsData",
  "widgets",
  "underscore"], (asyncQueue, dom, events, loader, config, widgetsData, widgets, _) ->


  #### Invoker(@reloadSections)
  #
  # Конструктор объекта действий при переходе, содежит в себе данные для переходов в обе стороны, используется в transitions
  # 
  Invoker = (@reloadSections) ->

    @_back = null
    @_forward = null
    @_is_applied = no
    @_is_sections_updated = no

  Invoker:: =

    initializeSections: () ->
      if not @_is_sections_updated or not @_forward or not @_back
        asyncQueue.next =>
          @_isCompressed = no
          reloadSectionsHtml = dom @reloadSections

          if not dom('title')[0]
            dom('head')[0].appendChild document.createElement 'title'

          @_back = {}
          @_forward = {}

          for element in reloadSectionsHtml.get()
            nodeName = element.nodeName.toLowerCase()

            if nodeName is config.sectionTagName
              selector = element.getAttribute "data-#{config.sectionSelectorAttributeName}"
            else if nodeName is 'title'
              selector = nodeName
            else
              continue

            if dom(selector)[0]?

              @_back[selector] = Array.prototype.slice.call dom(selector)[0].childNodes
              @_forward[selector] = Array.prototype.slice.call element.childNodes

        @_is_sections_updated = yes
        



    #### Invoker::update()
    #
    # Обновление данных о секциях
    #
    update: (sections) ->
      @reloadSections = sections
      @_is_sections_updated = no

    #### Invoker::run()
    #
    # Применение действий перехода, а также генерация данных для обратного перехода
    #
    run: ->

      if @_is_applied
        @undo()

      @initializeSections()

      asyncQueue.next =>

        forward: @_forward
        back: @_back

      @_insertSections()
      @_is_applied = yes

    #### Invoker::undo()
    #
    # Отмена действий перехода
    #
    undo: ->
      return false if @_is_applied isnt true
      asyncQueue.next =>
        forward: @_back or {}
        back: @_forward or {}

      @_insertSections()
      @_is_applied = no


    #### Invoker::_insertSections(forward, back)
    #
    # Вставка секций forward вместо секций back
    #
    _insertSections: (forward, back, selectors) ->

      asyncQueue.next (sections) ->
        insertionData = {}
        for selector in _.keys sections.back
          insertionData[selector] = 
            back: sections.back[selector]
            forward: sections.forward[selector]

        insertionData

      .each (section, selector, context) ->
        context.pause()

        loader.search section.forward, (widgetsList) =>
          container = dom(selector)[0]

          console.log "Container", container, selector

          for element in Array.prototype.slice.call container.childNodes
            element.parentNode.removeChild element

          for element in section.forward
            console.log "ELEMENT", element, container, selector
            container.appendChild element

          for element in section.back
            # if element.parentNode?
            #   element.parentNode.removeChild element

            for data in widgetsData element
              widgets.get(data.name, data.element)?.turnOff()

          
          
          context.resume()

      .next ->
        events.trigger "sections:inserted"

  return Invoker