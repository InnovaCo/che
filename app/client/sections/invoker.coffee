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
  "sections/parser",
  "dom",
  "events",
  "loader",
  "config",
  "utils/widgetsData",
  "widgets",
  "underscore"], (asyncQueue, sectionParser, dom, events, loader, config, widgetsData, widgets, _) ->


  #### Invoker(@reloadSections)
  #
  # Конструктор объекта действий при переходе, содежит в себе данные
  # для переходов в обе стороны ()
  # Принимает уже распарсенные sections.
  #
  Invoker = (@reloadSections) ->

    @_back = null
    @_forward = null
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

          if not dom('title')[0]
            dom('head')[0].appendChild document.createElement 'title'

          @_back = {}
          @_forward = {}

          for section in @reloadSections
            target = section.params.target
            continue if not target

            # Смотрим, есть ли вообще элемент с таким селектором
            # в существующем DOM-дереве
            containerElement = dom(target)[0]
            continue if not containerElement?

            container = _.extend(
              {element: containerElement, name: "", params: {}}
              sectionParser.parseSectionParams containerElement.getAttribute config.sectionSelectorAttributeName
            )

            # NodeList превращается в массив, потому что нам нужны только ссылки
            # на элементы, а не живые коллекции
            # {html: Array.prototype.slice.call section.element.childNodes}
            @_forward[target] = section
            @_back[target] = container

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

      @_insertSections()
      @_is_applied = yes

    #### Invoker::undo()
    #
    # Обратное по отношению к run действие, разве что не отменяется инициализация
    #
    undo: ->
      return false if @_is_applied isnt true
      asyncQueue.next =>
        forward: @_back
        back: @_forward

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
        for target in _.keys sections.back
          insertionData[target] =
            back: sections.back[target]
            forward: sections.forward[target]

        insertionData

      .each (section, target, context) ->
        # приостановка выполнения очереди, так как дальше опять
        # идет асинхронная
        #context.pause()  —— из-за этой штуки получается странный баг — cancel http запросов браузера
        forwardHtml = Array.prototype.slice.call section.forward.element.childNodes
        backHtml = Array.prototype.slice.call section.back.element.childNodes
          
        loader.search forwardHtml, (widgetsList) =>
          container = section.back.element
          container.setAttribute config.sectionSelectorAttributeName, "#{section.forward.name}: #{JSON.stringify section.forward.params}"
  
          for element in backHtml
            element.parentNode.removeChild element
  
          for element in forwardHtml
            container.appendChild element
  
          for element in section.back
            # if element.parentNode?
            #   element.parentNode.removeChild element
            for data in widgetsData element
              widgets.get(data.name, data.element)?.turnOff()

          # сообщаем про namespace, если таковой указан у элемента
          if section.back.ns?
            events.trigger "section-#{ns}:removed", [section.back] for type in section.back.ns
  
          if section.forward.ns?
            events.trigger "section-#{ns}:inserted", [section.forward] for type in section.forward.ns
  
          # возобновление выполнения очереди
          #context.resume()  —— FIXME: странный cancel http запросов картинок и т.д. в браузере

      .next ->
        # Сообщаем об окончании вставки секций
        events.trigger "sections:inserted"

  return Invoker