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
  # Конструктор объекта действий при переходе, содежит в себе данные для переходов в обе стороны ()
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
    # помещается в очередь asycQueue.
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

          for element in reloadSectionsHtml.get()
            nodeName = element.nodeName.toLowerCase()

            if nodeName is config.sectionTagName
              selector = element.getAttribute "data-#{config.sectionSelectorAttributeName}"
            else if nodeName is 'title'
              selector = nodeName
            else
              continue

            if dom(selector)[0]?
              # NodeList превращается в массив, потому что нам нужны только ссылки на элементы, а не живые коллекции
              @_back[selector] = Array.prototype.slice.call dom(selector)[0].childNodes
              @_forward[selector] = Array.prototype.slice.call element.childNodes

        @_is_sections_updated = yes
        



    #### Invoker::update()
    #
    # Обновление данных о секциях. Помечается, что секции не проинициализированны, что вызовет повторную иницализацию при вызове метода run
    #
    update: (sections) ->
      @reloadSections = sections
      @_is_sections_updated = no


    #### Invoker::run()
    #
    # Замена элементов подлежащих изъятию на новые элементы, инициализация перед этим, если необходимо
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
    # Обратное по отношению к run действие, разве что не отменяется инициализация
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
    # Вставка секций forward вместо секций back, выполняется асинхронно,
    # добавляя инструкции в очередь asynQuque
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
        # приостановка выполнения очереди, так как дальше опять идеи асинхронная инструкция
        context.pause()

        loader.search section.forward, (widgetsList) =>
          container = dom(selector)[0]

          for element in Array.prototype.slice.call container.childNodes
            element.parentNode.removeChild element

          for element in section.forward
            container.appendChild element

          for element in section.back
            # if element.parentNode?
            #   element.parentNode.removeChild element

            for data in widgetsData element
              widgets.get(data.name, data.element)?.turnOff()

          
          # возобновление выполнения очереди
          context.resume()

      .next ->
        # Сообщаем об окончании вставки секций
        events.trigger "sections:inserted"

  return Invoker