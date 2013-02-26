define [
  "sections/invoker",
  "sections/asyncQueue",
  "events",
  "utils/destroyer"], (Invoker, asyncQueue, events, destroyer) ->

  transitionsCompressDepth = 5
  transitionsDestroyDepth = 10
    #### Transition(@data)
  #
  # Конструктор переходов, переходы образуют между собой двусторонний связанный список
  # 
  Transition = (@state, last) ->
    @index = @state.index = @state.index or (last?.index + 1) or 0

    if last?
      @prev_transition = last
      last.next_transition = @
    if @state.sections?
      @_invoker = new Invoker @state.sections
      last.next()

    events.bind "pageTransition:success", (info) =>
      if @index < info.transition.index - transitionsDestroyDepth
        @destroy()

    return @

  Transition:: =
  
    #### Transition::update(data)
    #
    # Обновляет данные секций для перехода. Обновление происходит только если данные отличаются от текущих
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
        if @_invoker? and @state.sections?
          @_invoker.update @state.sections
        else if @state.sections?
          @_invoker = new Invoker @state.sections

        @invoke()

        asyncQueue.next ->
          events.trigger "pageTransition:updated", {}


    destroy: () ->
      destroyer @


    #### Transition::next([to_transition])
    #
    # Переход вперед. Если переданы параметры перехода, то создается новый объект и ссылка на него записыватся в @next
    #
    next: (to_transition) ->
      transition = @
      if to_transition isnt @index and @next_transition?
        transition = @next_transition
        @next_transition.invoke()
        if to_transition? then @next_transition.next(to_transition)

      if to_transition is @index or not to_transition
        asyncQueue.next ->
          events.trigger "pageTransition:success",
            transition: transition
      @

    #### Transition::prev([to_transition])
    #
    # Переход назад
    #
    prev: (to_transition) ->
      transition = @
      if to_transition isnt @index and @prev_transition?
        transition = @prev_transition
        @undo()
        if to_transition? then @prev_transition.prev(to_transition)

      if to_transition is @index or not to_transition
        asyncQueue.next ->
          events.trigger "pageTransition:success",
            transition: transition
      @


    #### Transition::undo()
    #
    # Отмена действий при переходе
    #
    undo: () ->
      @_invoker?.undo()
      events.trigger "transition:undo", @
      events.trigger "transition:current:update", @prev_transition

    #### Transition::invoke()
    #
    # Применение действий перехода
    #
    invoke: () ->
      @_invoker?.run()
      events.trigger "transition:invoked", @
      events.trigger "transition:current:update", @


  return Transition