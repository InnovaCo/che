describe "utils/ticker module", ->
  ticker = null
  callback = null
  beforeEach ->
    callback = jasmine.createSpy('callback')
    require ["utils/ticker"], (tickerModule) ->
      ticker = tickerModule

    jasmine.Clock.useMock()
    console.log setTimeout, jasmine.Clock.installed.setTimeout, jasmine.Clock.tick
    waitsFor ->
      ticker?

  describe "creating ticker", ->
    it "should create ticker", ->
      newTicker = ticker 10, callback

      jasmine.Clock.tick 101

      expect(newTicker).toBeObject()
      expect(newTicker._callbacks[0]).toBe(callback)
      expect(newTicker._callbacks).toBeArray()
      expect(newTicker._callbacks.length).toBe 1
      expect(newTicker.period).toBe 10

      expect(callback).not.toHaveBeenCalled()

    it "should create ticker, without callback", ->
      newTicker = ticker 10

      expect(newTicker).toBeObject()
      expect(newTicker._callbacks).toBeArray()
      expect(newTicker._callbacks.length).toBe 0
      expect(newTicker.period).toBe 10

    it "should create ticker, without callback, but append it later", ->
      newTicker = ticker 10

      newTicker.listen callback

      expect(newTicker._callbacks[0]).toBe(callback)
      expect(newTicker._callbacks.length).toBe 1

  describe "work with ticker", ->
    newTicker = null
    beforeEach ->
      newTicker = ticker(10, callback)

    it "should start ticker mock", ->
      call2 = jasmine.createSpy('call2')
      jasmine.Clock.useMock()
      newTicker = ticker 10, call2
      newTicker.start()
      jasmine.Clock.tick 101

      expect(call2).toHaveBeenCalled()
      expect(call2.calls.length).toBeGreaterThan 8

    it "should stop ticker", ->
      newTicker = ticker 10, callback
      newTicker.start()
      newTicker.stop()
      jasmine.Clock.tick 101

      expect(callback).not.toHaveBeenCalled()