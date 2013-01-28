(function() {

  describe("utils/ticker module", function() {
    var callback, ticker;
    ticker = null;
    callback = null;
    beforeEach(function() {
      callback = jasmine.createSpy('callback');
      require(["utils/ticker"], function(tickerModule) {
        return ticker = tickerModule;
      });
      jasmine.Clock.useMock();
      console.log(setTimeout, jasmine.Clock.installed.setTimeout, jasmine.Clock.tick);
      return waitsFor(function() {
        return ticker != null;
      });
    });
    describe("creating ticker", function() {
      it("should create ticker", function() {
        var newTicker;
        newTicker = ticker(10, callback);
        jasmine.Clock.tick(101);
        expect(newTicker).toBeObject();
        expect(newTicker._callbacks[0]).toBe(callback);
        expect(newTicker._callbacks).toBeArray();
        expect(newTicker._callbacks.length).toBe(1);
        expect(newTicker.period).toBe(10);
        return expect(callback).not.toHaveBeenCalled();
      });
      it("should create ticker, without callback", function() {
        var newTicker;
        newTicker = ticker(10);
        expect(newTicker).toBeObject();
        expect(newTicker._callbacks).toBeArray();
        expect(newTicker._callbacks.length).toBe(0);
        return expect(newTicker.period).toBe(10);
      });
      return it("should create ticker, without callback, but append it later", function() {
        var newTicker;
        newTicker = ticker(10);
        newTicker.listen(callback);
        expect(newTicker._callbacks[0]).toBe(callback);
        return expect(newTicker._callbacks.length).toBe(1);
      });
    });
    return describe("work with ticker", function() {
      var newTicker;
      newTicker = null;
      beforeEach(function() {
        return newTicker = ticker(10, callback);
      });
      it("should start ticker mock", function() {
        var call2;
        call2 = jasmine.createSpy('call2');
        jasmine.Clock.useMock();
        newTicker = ticker(10, call2);
        newTicker.start();
        jasmine.Clock.tick(101);
        expect(call2).toHaveBeenCalled();
        return expect(call2.calls.length).toBeGreaterThan(9);
      });
      return it("should stop ticker", function() {
        newTicker = ticker(10, callback);
        newTicker.start();
        newTicker.stop();
        jasmine.Clock.tick(101);
        return expect(callback).not.toHaveBeenCalled();
      });
    });
  });

}).call(this);
