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
      console.log "start", @period
      @_interval = setTimeout =>
        console.log "call setTimeout: ", @period, @_callbacks
        @_tick()
        @start()
      , @period


    stop: () ->
      clearTimeout @_interval

    _tick: () ->
      for callback in @_callbacks
        setTimeout callback


  (period, callback) ->
    new Ticker period, callback