#### *module* sections/invoker
#
#
# Модуль для непосредственного выполнения переходов.
# Получая данные о секциях, создает набор объектов, необходимых для
# замены DOM-элементов. Создаются массивы элеметов, которые необходимо
# изъять из DOM, а также те, которые должны быть вставлены вместо.
# Операция смены секции полностью обратима и так же кроме вставки/удаления
# элементов подразумевает включение (инициализацию)/отключение виджетов.
#

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
  # Конструктор объекта действий при переходе, содежит в себе данные
  # для переходов в обе стороны ()
  #
  Invoker = (@reloadSections) ->

    @_back = null
    @_backNS = null
    @_forward = null
    @_forwardNS = null
    @_is_applied = no
    @_is_sections_updated = no

  Invoker:: =

    #### Invoker.initializeSections()
    #
    # Инициализация объектов перехода.
    # Создается массив с ссылками на элементы, которые нужно изъять,
    # и создаются DOM-элементы для вставки.
    # Выполняется асинхнонно, то есть инструкция для инициализации
    # помещается в очередь asyncQueue.
    #
    initializeSections: () ->
      if not @_is_sections_updated or not @_forward or not @_back
        asyncQueue.next =>
          @_isCompressed = no

          reloadSectionsHtml = dom @reloadSections

          if not dom('title')[0]
            dom('head')[0].appendChild document.createElement 'title'

          @_back = {}
          @_forward = {}
          @_backNS = {}
          @_forwardNS = {}

          for element in reloadSectionsHtml.get()
            nodeName = element.nodeName.toLowerCase()


            if nodeName is config.sectionTagName
              selector = element.getAttribute "data-#{config.sectionSelectorAttributeName}"
              selectorNS = element.getAttribute "data-#{config.sectionSelectorNSAttributeName}"
            else if nodeName is 'title'
              selector = nodeName
            else
              continue

            container = dom(selector)[0]
            if container?
              # NodeList превращается в массив, потому что нам нужны только ссылки
              # на элементы, а не живые коллекции
              @_back[selector] = Array.prototype.slice.call container.childNodes
              @_forward[selector] = Array.prototype.slice.call element.childNodes
              backSelectorNS = container.getAttribute "data-#{config.sectionSelectorNSAttributeName}"
              
              if backSelectorNS?
                backSelectorNS = backSelectorNS.split config.sectionNSdelimiter
                @_backNS[selector] = _.compact backSelectorNS

              if selectorNS?
                # TODO: trim values for trailing whitespaces
                selectorNS = selectorNS.split config.sectionNSdelimiter
                @_forwardNS[selector] = _.compact selectorNS

        @_is_sections_updated = yes
        



    #### Invoker::update()
    #
    # Обновление данных о секциях. Помечается, что секции не проинициализированны,
    # что вызовет повторную иницализацию при вызове метода run
    #
    update: (sections) ->
      @reloadSections = sections
      @_is_sections_updated = no


    #### Invoker::run()
    #
    # Замена элементов подлежащих изъятию на новые элементы,
    #инициализация перед этим, если необходимо
    #
    run: ->

      if @_is_applied
        @undo()

      @initializeSections()

      asyncQueue.next =>

        back: @_back
        forward: @_forward
        backNS: @_backNS
        forwardNS: @_forwardNS

      @_insertSections()
      @_is_applied = yes

    #### Invoker::undo()
    #
    # Обратное по отношению к run действие, разве что не отменяется инициализация
    #
    undo: ->
      return false if @_is_applied isnt true
      asyncQueue.next =>
        forward: @_back or {}
        back: @_forward or {}
        forwardNS: @_backNS or {}
        backNS: @_forwardNS or {}

      @_insertSections()
      @_is_applied = no


    #### Invoker::_insertSections(forward, back)
    #
    # Вставка секций forward вместо секций back, выполняется асинхронно,
    # добавляя инструкции в очередь asynQueue
    #
    _insertSections: () ->

      asyncQueue.next (sections) ->

        insertionData = {}
        for selector in _.keys sections.back
          insertionData[selector] =
            back: sections.back[selector]
            forward: sections.forward[selector]

          if sections.forwardNS?[selector]?
            insertionData[selector].forwardNS = sections.forwardNS[selector]

          if sections.backNS?[selector]?
            insertionData[selector].backNS = sections.backNS[selector]

        insertionData

      .each (section, selector, context) ->
        # приостановка выполнения очереди, так как дальше опять
        # идет асинхронная
        context.pause()

        loader.search section.forward, (widgetsList) =>
          container = dom(selector)[0]
          if section.forwardNS
            container.setAttribute "data-#{config.sectionSelectorNSAttributeName}", section.forwardNS.join( config.sectionNSdelimiter )

          for element in Array.prototype.slice.call container.childNodes
            element.parentNode.removeChild element

          for element in section.forward
            container.appendChild element

          for element in section.back
            # if element.parentNode?
            #   element.parentNode.removeChild element

            for data in widgetsData element
              widgets.get(data.name, data.element)?.turnOff()

          # сообщаем про namespace, если таковой указан у элемента
          if section.backNS
            events.trigger "section-#{ns}:removed", [section.back] for ns in section.backNS

          if section.forwardNS
            events.trigger "section-#{ns}:inserted", [section.forward] for ns in section.forwardNS

          # возобновление выполнения очереди
          context.resume()

      .next ->
        # Сообщаем об окончании вставки секций
        events.trigger "sections:inserted"

  return Invoker