(function() {

  describe("events module", function() {
    describe("check interface", function() {
      var events;
      events = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          events._data.previousArgs = {};
          return events._data.handlers = {};
        });
      });
      return it("should contain once, bind, unbind, trigger, pub, sub, unsub functions", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          expect(events.once).toBeFunction();
          expect(events.bind).toBeFunction();
          expect(events.unbind).toBeFunction();
          expect(events.trigger).toBeFunction();
          expect(events.pub).toBeFunction();
          expect(events.sub).toBeFunction();
          return expect(events.unsub).toBeFunction();
        });
      });
    });
    describe("binding handlers to events", function() {
      var bindSpy, events, onceSpy;
      events = null;
      bindSpy = null;
      onceSpy = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          events._data.previousArgs = {};
          events._data.handlers = {};
          bindSpy = spyOn(events, "bind").andCallThrough();
          return onceSpy = spyOn(events, "once").andCallThrough();
        });
      });
      it("should bind handler", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = function() {};
          events.bind("testEvent", handler, {});
          expect(handler.id).toBeDefined();
          expect(events._data.handlers["testEvent"]).toBeDefined();
          expect(events._data.handlers["testEvent"][handler.id].options).toBeDefined();
          return expect(events._data.handlers["testEvent"][handler.id].id).toBe(handler.id);
        });
      });
      it("should unbind handler", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = function() {};
          events.bind("testEvent", handler, {});
          expect(events._data.handlers["testEvent"][handler.id].id).toBe(handler.id);
          events.unbind("testEvent", handler);
          return expect(events._data.handlers["testEvent"][handler.id]).not.toBeDefined();
        });
      });
      it("should call handler after binding (remember option is true)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = jasmine.createSpy("handler");
          events.pub('testEvent', {
            testData: 'testData'
          });
          events.bind("testEvent", handler, {
            isSync: true,
            remember: true
          });
          return expect(handler).toHaveBeenCalled();
        });
      });
      it("shouldn't call handler after binding (remember option is false)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = jasmine.createSpy("handler");
          events.pub('testEvent', {
            testData: 'testData'
          });
          events.bind("testEvent", handler, {
            isSync: true
          });
          return expect(handler).not.toHaveBeenCalled();
        });
      });
      return it("should bind handler only once", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler, handlerI;
          handlerI = false;
          handler = jasmine.createSpy("handler").andCallFake(function() {
            var handlerIsCalled;
            return handlerIsCalled = true;
          });
          events.once('testEvent', handler, {
            isSync: true
          });
          expect(handler).not.toHaveBeenCalled();
          events.pub('testEvent', {
            testData: 'testData'
          });
          expect(handler).toHaveBeenCalled();
          events.pub('testEvent', {
            testData: 'testData'
          });
          return expect(handler.calls.length).not.toBeGreaterThan(1);
        });
      });
    });
    describe("calling handlers", function() {
      var events;
      events = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          events._data.previousArgs = {};
          return events._data.handlers = {};
        });
      });
      it("should call handler syncronously (isSync option is true)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var syncHandler;
          syncHandler = jasmine.createSpy("syncHandler");
          events.bind("testEvent", syncHandler, {
            isSync: true
          });
          events.pub('testEvent', {
            testData: 'testData'
          });
          return expect(syncHandler).toHaveBeenCalled();
        });
      });
      return it("should call handler asyncronously (isSync option is false)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var asyncHandler;
          asyncHandler = jasmine.createSpy("asyncHandler");
          events.bind("testEvent", asyncHandler);
          events.pub('testEvent', {
            testData: 'testData'
          });
          expect(asyncHandler).not.toHaveBeenCalled();
          waitsFor(function() {
            return 0 < asyncHandler.calls.length;
          });
          return runs(function() {
            return expect(asyncHandler).toHaveBeenCalled();
          });
        });
      });
    });
    return describe("triggering events", function() {
      var events;
      events = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          events._data.previousArgs = {};
          return events._data.handlers = {};
        });
      });
      it("should call handlers after triggering event", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var bind, handler, handlers, _i, _len;
          handlers = [];
          handlers.push(jasmine.createSpy("handler_1"));
          handlers.push(jasmine.createSpy("handler_2"));
          handlers.push(jasmine.createSpy("handler_3"));
          handlers.push(jasmine.createSpy("handler_4"));
          handlers.push(jasmine.createSpy("handler_5"));
          bind = function(handler) {
            return events.bind("testEvent", handler, {
              isSync: true
            });
          };
          for (_i = 0, _len = handlers.length; _i < _len; _i++) {
            handler = handlers[_i];
            bind(handler);
          }
          events.trigger("testEvent", {
            testData: "testData"
          });
          expect(handlers[0]).toHaveBeenCalled();
          expect(handlers[1]).toHaveBeenCalled();
          expect(handlers[2]).toHaveBeenCalled();
          expect(handlers[3]).toHaveBeenCalled();
          return expect(handlers[4]).toHaveBeenCalled();
        });
      });
      return it("should save last event data", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          expect(events._data.previousArgs["testEvent"]).not.toBeDefined();
          events.trigger("testEvent", {
            testData: "testData"
          });
          expect(events._data.previousArgs["testEvent"]).toBeDefined();
          return expect(events._data.previousArgs["testEvent"].testData).toBe("testData");
        });
      });
    });
  });

}).call(this);
