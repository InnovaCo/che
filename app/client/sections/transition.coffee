#### *module* sections/transition
#
# Представляет собой звено для цепочки переходов, получая данные
# о секциях, и ссылку на предыдущий переход, конструктор Transition
# создает объект Invoker, устанавливает ссылку на новый объект
# в предыдущем объекте Transition, и сохраняет ссылку на предыдущий
# Transition.
# Кроме того проходит по цепочке и удаляет записи, если длина
# цепочки превышает 10 объектов
#
define [
  "sections/parser",
  "sections/invoker",
  "sections/asyncQueue",
  "events",
  "utils/destroyer",
  "history",
  "config"
], (sectionParser, Invoker, asyncQueue, events, destroyer, history, config) ->

  transitionsCompressDepth = 5
  transitionsDestroyDepth = 10

  #### Transition(@data)
  #
  # Конструктор переходов, переходы образуют между собой двусторонний
  # связанный список
  #
  Transition = (@state, last) ->
    if !@state?.che
      @state = new history.CheState @state

    @index = @state.index = @state.index or (last?.index + 1) or 0

    if @state.sections?
      sections = sectionParser.parseSections @state.sections
      @_invoker = new Invoker (sections if sections), @state

    if last?
      @prev_transition = last
      last.next_transition = @
      last.next()

      # Удаление старых записей.
      # Стоит отметить, что проход всей цепочки вполне себе хороший
      # способ удалить старые записи, так как позволяет удалять
      # старые записи именно в этой цепочке переходов, не трогая остальные,
      # которые могут быть созданы при многочиленных переходах по истории
      # и ссылкам на странице (история может ветвиться, но цепочка от конца
      # к началу не имеет ветвления)

      depth = transitionsDestroyDepth
      prevTransition = @
      while depth--
        prevTransition = prevTransition.prev_transition
        if not prevTransition?
          break

      prevTransition?.destroy()

    return @

  Transition:: =

    #### Transition::update(data)
    #
    # Обновляет данные секций для перехода. Если новые данные совпадают
    # с предыдущими, то ничего не происходит, иначе запускается механизм
    # обновления секций, прежние секции удаляются, вместо них вставляются
    # новые.
    #
    update: (state) ->
      isStateTheSame = no
      if @state.url is state.url
        isStateTheSame = @state.sections is state.sections
      else
        return

      if not isStateTheSame
        state.index = @index
        @state = state
        sections = sectionParser.parseSections @state.sections
        
        if @_invoker? and sections?
          @_invoker.update sections
        else if sections?
          @_invoker = new Invoker sections, @state

        @invoke()

        asyncQueue.next ->
          events.trigger "pageTransition:updated", {}


    destroy: () ->
      destroyer @


    #### Transition::next([to_transition])
    #
    # Переход вперед. Требует необязательный параметр to_transition,
    # в котором должен находится индекс интересующего нас перехода.
    #
    # Полезно, когда нужно перейти на несколько шагов вперед, в случае
    # отсутсвия параметра, просто происходит переход на один шаг.
    #
    # Если параметр совпадает с индексом перехода, то в очередь asynQueue
    # добавляется инструкция, вызывающая событие "pageTransition:success",
    # которое означает, что завершилась цепочка переходов
    #
    next: (to_transition) ->
      transition = @
      if to_transition isnt @index and @next_transition?
        transition = @next_transition
        @next_transition.invoke()
        if to_transition? then @next_transition.next(to_transition)

      if to_transition is @index or not to_transition
        asyncQueue.next =>
          @restoreScroll transition, to_transition
          events.trigger "pageTransition:success",
            transition: transition
      @


    #### Transition::next([to_transition])
    #
    # Переход назад. Работает аналогично Transition::next требует
    # необязательный параметр to_transition, только переходы идут
    # в другом направлении.
    #
    prev: (to_transition) ->
      transition = @
      if to_transition isnt @index and @prev_transition?
        transition = @prev_transition
        @undo()
        if to_transition? then @prev_transition.prev(to_transition)

      if to_transition is @index or not to_transition
        asyncQueue.next =>
          @restoreScroll transition, to_transition
          events.trigger "pageTransition:success",
            transition: transition
      @


    #### Transition::undo()
    #
    # Отмена действий перехода. Помимо отката действий объекта Invoker,
    # запускает события "transition:undo" и "transition:current:update",
    # где в "transition:current:update" передается ссылка на предыдущий
    # переход, а в "transition:undo" на текущий
    #
    undo: () ->
      @_invoker?.undo()
      events.trigger "transition:undo", @
      events.trigger "transition:current:update", @prev_transition


    #### Transition::invoke()
    #
    # Применение действий перехода. Помимо применения действий
    # объекта Invoker, запускает события "transition:invoked"
    # и "transition:current:update", где в "transition:current:update"
    # и "transition:invoked" передается ссылка на текущий переход
    #
    invoke: () ->
      @_invoker?.run()
      events.trigger "transition:invoked", @
      events.trigger "transition:current:update", @


    restoreScroll: (transition, index) ->
      window.scrollTo(transition.state.scrollPos.left or 0, transition.state.scrollPos.top or 0) if !!config.autoScrollOnTransitions and (!index? or index == transition.index) and transition.state.scrollPos?


  return Transition