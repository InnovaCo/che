#### *module* sections
#
# Основной модуль для работы с секциями, умеет загружать,
# кэшировать и менять секции с помощью модулей
# "sections/loader", "sections/transition", "sections/cache".
# Также не будет работать, если модуль history возвращает false
# (это происходит при отсутствии historyAPI)
#
define [
  "history",
  "events",
  "sections/loader",
  "sections/transition",
  "sections/cache",
  "utils/errorHandlers/errorHandler",
  "dom",
  "widgets"
], (history, events, sectionsLoader, Transition, cache, errorHandler, dom, widgets) ->
  return false if not history
  sectionIsAnimating = false

  #### transitions
  #
  # Менеджер переходов, создает, либо достает уже ранее созданные переходы
  #

  transitions =
    ###### transitions.last
    # Самый последний созданный переход
    #
    last: null

    ###### transitions.current
    # Текущий примененный переход, в случае, когда был переход
    # назад по истории, current не равен last
    #
    current: null

    ###### transitions.create(state)
    # Создает новый объект перехода, устанавливает в нем ссылки
    # на предыдущий, а сам новый теперь записывается в last,
    # кроме того, обновляются, либо записываются данные
    # в historyState. Если же такой переход уже был создан
    # (state имеет параметр index), то совершается ищем по индексу
    # нужный переход, применяем его (функция transitions.go)
    # и обновляем его данные
    #
    create: (state = {}) ->
      state.index = state.index or (@last?.index + 1) or 0

      if state? and !state.che
        state = new history.CheState state

      if !state.userReplaceState
        if transitions.current? and !transitions.current.state.userReplaceState
          transitions.current.state.updateScroll?()
        state.scrollPos =
          top: 0
          left: 0

      if @last? and state.index <= @last.index
        transition = @go state.index
        transition.update state
        return transition
      else
        isNewState = (history.state or {}).url isnt state.url
        method = if isNewState and !state.userReplaceState then "pushState" else "replaceState"
        history[method] state, state.title, state.url
        @last = new Transition state, (if @current?.next_transition? and @current.next_transition.index < state.index then @current else @last)
        return @last

    ###### transitions.go(index)
    # Запускает все переходы от текущего до перехода с указанным индексом
    #

    go: (index) ->
      if not @current
        return @create()

      return @current if index is @current?.index
      direction = if @current.index < index then "next" else "prev"
      return @current[direction](index)

  #### Обработка события "transition:current:update"
  #
  # Обновление ссылки на текущий переход
  #
  events.bind "transition:current:update", (transition) ->
    transitions.current = transition

  #### Обработка события "sections:loaded"
  #
  # Секции сохраняются в кэш, и далее отдаются на инициализацию
  #
  events.bind "sections:loaded", (state) ->
    switchEvent = state.sectionsParams?.switchEvent
    completeHandler = ->
      cache.save state
      transitions.create state
    hasActiveSwitchManager = false
    switchManagers = []

    if switchEvent
      for widget in widgets._switchManagers
        animationHandler = widget[widget.switchEvents[switchEvent]]

        if widget._isOn and typeof animationHandler == "function"
          hasActiveSwitchManager = true
          switchManagers.push widget.id
          sectionIsAnimating = true
          animationHandler.call widget, ->
            for id, i in switchManagers
              if widget.id == id
                switchManagers.splice i, 1

                if !switchManagers.length
                  completeHandler()
                  sectionIsAnimating = false
                break

    completeHandler() if !hasActiveSwitchManager

  #### Обработка события "sections:error"
  #
  # Действия в случае ошибке при запросе секций
  #
  events.bind "sections:error", (state, errorCode, errorMessage) ->
    errorHandler.processError "sectionLoadError",
      state: state,
      errorCode: errorCode,
      errorMessage: errorMessage

  #### Обработка события pageTransition:init
  #
  # Проверяется, есть ли такие секции уже в кэше, если есть,
  # то используем их и параллельно смотрим на сервере
  #
  events.bind "pageTransition:init", (url, sectionsHeader, method, formData, params) ->
    if !sectionIsAnimating
      state = cache.get url, sectionsHeader

      index = transitions.last?.index + 1 or 0
      if state?
        state.index = index
        transitions.create state

      sectionsLoader url, method, sectionsHeader, index, formData, params


  #### Обработка события history:popState
  #
  # Переходит до нужного состояния и проверяет обновления на сервере
  #
  events.bind "history:popState", (state) ->
    if state?
      transitions.go state.index

      if state.url? and state.sectionsHeader?.length and state.method?.toLowerCase() != 'post'
        sectionsLoader state.url, state.method, state.sectionsHeader, state.index
    else if transitions.last?
      # Если переданный state равен null, то создаем новый и убеждаемся что при этом произойдет
      # replaceState
      transitions.create(new history.CheState index: transitions.last.state.index + 1, replaceState: true)
    # here ask server for updated sections (history case)

  #### Событие transition:current:update
  #
  # Создается первый пустой переход, он отражает текущее состояние страницы
  #
  events.trigger "transition:current:update", transitions.create()

  return {
    _transitions: transitions
  }