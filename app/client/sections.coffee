define ["history", "events", "sections/loader", "sections/transition", "utils/storage"],  (history, events, sectionsLoader, Transition, storage) ->
  return false if not history

  helpers = 
    stateId: (state) ->
      return state.url + "|header:#{state.header}"

  #### transitions
  #
  # Менеджер переходов, создает, либо достает уже ранее созданные переходы
  # 

  transitions =
    last: null
    current: null
    create: (state) ->
      state = state or {index: 0}
      if @last? and state.index <= @last.index
        transition = @go state.index
        transition.update state
        return transition
      else
        isNewState = (history.state or {}).url isnt state.url
        method = if isNewState then "pushState" else "replaceState"
        history[method] state, state.title, state.url
        @last = new Transition state, @last
        return @last

    go: (index) ->
      if not @current
        return @create()

      return @current if index is @current?.index
      direction = if @current.index < index then "next" else "prev"
      return @current[direction](index)


  events.bind "transition:current:update", (transition) ->
    transitions.current = transition;

  #### Обработка "sections:loaded"
  #
  # Секции сохраняются в localStorage, и далее отдаются на инициализацию
  #
  events.bind "sections:loaded", (state) ->
    storage.save "sectionsHistory", helpers.stateId(state), state
    transitions.create state

  #### Обработка pageTransition:init
  #
  # Проверяется, есть ли такие секции уже в localStorage, если есть, то используем их и параллельно смотрим на сервере
  #
  events.bind "pageTransition:init", (url, sectionsHeader, method) ->
    state = storage.get "sectionsHistory", helpers.stateId
      url: url,
      header: sectionsHeader

    index = transitions.last?.index + 1 or 0
    if state?
      state.index = index
      transitions.create state

    sectionsLoader url, method, sectionsHeader, index


  #### Обработка history:popState
  #
  # Переходит до нужного состояния и проверяет обновления на сервере
  #
  events.bind "history:popState", (state) ->
    if state?
      transitions.go state.index
      if state.url?
        sectionsLoader state.url, state.method, state.sectionsHeader, state.index
    # here ask server for updated sections (history case)

  events.trigger "transition:current:update", transitions.create()

  return {
    _transitions: transitions
  }