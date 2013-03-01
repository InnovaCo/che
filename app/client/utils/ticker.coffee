#### *module* utils/ticker
#
# Таймер, которые срабатывает после определенного промежутка, 
# по идее должен быть использован для удаления записей истории по таймауту
# 


define [], () ->
  Ticker = (period, callback) ->
    @period = parseInt period, 10
    @_callbacks = []
    if callback
      @listen callback
    @

  Ticker:: =
    listen: (callback) ->
      @_callbacks.push callback
      @

    start: () ->
      @_interval = setTimeout =>
        @_tick()
        @start()
      , @period


    stop: () ->
      clearTimeout @_interval

    _tick: () ->
      for callback in @_callbacks
        setTimeout callback

  # timer(period, [callback])
  #
  # Каждый раз при обращении к модулю, создается новый таймер, причем не обязательно сразу отдавать обработчика,
  # его можно будет добавить позже c помощью метода listen
  #
  #
  (period, callback) ->
    new Ticker period, callback