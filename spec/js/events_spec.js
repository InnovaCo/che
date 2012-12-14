(function() {

  describe("events module", function() {
    describe("check interface", function() {
      var events;
      events = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          return events.list = {};
        });
      });
      return it("should contain 'once', 'bind', 'unbind', 'trigger', 'create' functions", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          expect(events.create).toBeFunction();
          expect(events.once).toBeFunction();
          expect(events.bind).toBeFunction();
          expect(events.unbind).toBeFunction();
          return expect(events.trigger).toBeFunction();
        });
      });
    });
    describe("creating new Event", function() {
      var events;
      events = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          return events.list = {};
        });
      });
      return it("events.create should return CustomEvent", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var CustomEvent;
          CustomEvent = events.create("testEvent");
          expect(CustomEvent).toBeObject();
          expect(CustomEvent.name).toBe("testEvent");
          return expect(CustomEvent._handlers).toBeEmpty();
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
          events.list = {};
          bindSpy = spyOn(events, "bind").andCallThrough();
          return onceSpy = spyOn(events, "once").andCallThrough();
        });
      });
      it("should bind handler", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler, testEvent;
          handler = function() {};
          testEvent = events.bind("bindTestEvent", handler, {});
          expect(handler.id).toBeDefined();
          expect(events.list['bindTestEvent']._handlers).toBeDefined();
          expect(events.list['bindTestEvent']._handlers[handler.id].options).toBeDefined();
          return expect(events.list['bindTestEvent']._handlers[handler.id].id).toBe(handler.id);
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
          expect(events.list['testEvent']._handlers[handler.id].id).toBe(handler.id);
          events.unbind("testEvent", handler);
          return expect(events.list['testEvent']._handlers[handler.id]).not.toBeDefined();
        });
      });
      it("should call handler after binding (recall option is true)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = jasmine.createSpy("handler");
          events.trigger('testEvent', {
            testData: 'testData'
          });
          events.bind("testEvent", handler, {}, {
            isSync: true,
            recall: true
          });
          return expect(handler).toHaveBeenCalled();
        });
      });
      it("shouldn't call handler after binding (recall option is false)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = jasmine.createSpy("handler");
          events.trigger('testEvent', {
            testData: 'testData'
          });
          events.bind("testEvent", handler, {}, {
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
          events.once('testEvent', handler, {}, {
            isSync: true
          });
          expect(handler).not.toHaveBeenCalled();
          events.trigger('testEvent', {
            testData: 'testData'
          });
          expect(handler).toHaveBeenCalled();
          events.trigger('testEvent', {
            testData: 'testData'
          });
          return expect(handler.calls.length).not.toBeGreaterThan(1);
        });
      });
    });
    describe("binding handler to compound events", function() {
      var events;
      events = null;
      beforeEach(function() {
        events = null;
        return require(["events"], function(eventsModule) {
          events = eventsModule;
          return events.list = {};
        });
      });
      it("should call handler after calling all events from list", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = jasmine.createSpy("compoundHandler");
          events.bind("one, two, three", handler, {}, {
            isSync: true
          });
          events.trigger('one', {
            data: "one"
          });
          expect(handler).not.toHaveBeenCalled();
          events.trigger('two', {
            data: "two"
          });
          expect(handler).not.toHaveBeenCalled();
          events.trigger('three', {
            data: "three"
          });
          expect(handler).toHaveBeenCalled();
          expect(handler.calls.length).toBe(1);
          return expect(handler.mostRecentCall.args[0]).toEqual({
            one: {
              0: {
                data: 'one'
              },
              1: {
                name: 'one'
              }
            },
            two: {
              0: {
                data: 'two'
              },
              1: {
                name: 'two'
              }
            },
            three: {
              0: {
                data: 'three'
              },
              1: {
                name: 'three'
              }
            }
          });
        });
      });
      return it("should call handler every time after calling all events from list", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var handler;
          handler = jasmine.createSpy("compoundHandler");
          events.bind("one, two, three", handler, {}, {
            isSync: true
          });
          events.trigger('one', {
            data: "one"
          });
          expect(handler).not.toHaveBeenCalled();
          events.trigger('two', {
            data: "two"
          });
          expect(handler).not.toHaveBeenCalled();
          events.trigger('three', {
            data: "three"
          });
          expect(handler).toHaveBeenCalled();
          expect(handler.calls.length).toBe(1);
          events.trigger('one', {
            data: "one"
          });
          events.trigger('two', {
            data: "two"
          });
          expect(handler.calls.length).toBe(1);
          events.trigger('one', {
            data: "one"
          });
          events.trigger('two', {
            data: "two"
          });
          events.trigger('three', {
            data: "three"
          });
          expect(handler.calls.length).toBe(2);
          events.trigger('one', {
            data: "one"
          });
          events.trigger('two', {
            data: "two"
          });
          events.trigger('three', {
            data: "three"
          });
          expect(handler.calls.length).toBe(3);
          events.trigger('three', {
            data: "three"
          });
          return expect(handler.calls.length).toBe(3);
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
          return events.list = {};
        });
      });
      it("should call handler syncronously (isSync option is true)", function() {
        waitsFor(function() {
          return events !== null;
        });
        return runs(function() {
          var syncHandler;
          syncHandler = jasmine.createSpy("syncHandler");
          events.bind("testEvent", syncHandler, {}, {
            isSync: true
          });
          events.trigger('testEvent', {
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
          events.trigger('testEvent', {
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
          return events.list = {};
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
            console.log("bind events");
            return events.bind("testEvent", handler, {}, {
              isSync: true
            });
          };
          for (_i = 0, _len = handlers.length; _i < _len; _i++) {
            handler = handlers[_i];
            bind(handler);
          }
          console.log("trigger events");
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
          expect(events.list['testEvent']).not.toBeDefined();
          events.trigger("testEvent", {
            testData: "testData"
          });
          expect(events.list['testEvent']).toBeDefined();
          return expect(events.list['testEvent']._lastArgs[0].testData).toBe("testData");
        });
      });
    });
  });

}).call(this);
