(function() {

  describe("widgets module", function() {
    var anotherEventHandlerSpy, clickHandlerSpy, clickSpy, dom, events, sampleEventSpy, sampleWidget, triggerMouseEvent, widgets;
    widgets = null;
    dom = null;
    events = null;
    sampleWidget = null;
    clickSpy = null;
    sampleEventSpy = null;
    clickHandlerSpy = null;
    anotherEventHandlerSpy = null;
    triggerMouseEvent = null;
    beforeEach(function() {
      triggerMouseEvent = function(eventName, element) {
        var event;
        if (document.createEvent) {
          event = document.createEvent("MouseEvents");
          event.initEvent(eventName, true, true);
        } else {
          event = document.createEventObject();
          event.eventType = eventName;
        }
        event.eventName = eventName;
        event.memo = {};
        if (document.createEvent) {
          return element.dispatchEvent(event);
        } else {
          return element.fireEvent("on" + event.eventType, event);
        }
      };
      clickSpy = jasmine.createSpy('clickSpy');
      clickHandlerSpy = jasmine.createSpy('clickHandlerSpy');
      sampleEventSpy = jasmine.createSpy("sampleEventSpy");
      anotherEventHandlerSpy = jasmine.createSpy("anotherEventHandlerSpy");
      affix("div.widget ul li div.mouser div.action");
      sampleWidget = {
        domEvents: {
          "click div.action": clickSpy,
          "click div.mouser": "clickHandler"
        },
        clickHandler: clickHandlerSpy,
        moduleEvents: {
          "sampleEvent": sampleEventSpy,
          "anotherEvent": "anotherEventHandler"
        },
        anotherEventHandler: anotherEventHandlerSpy,
        someProperty: "someProperty",
        init: function(element) {
          return dom(element).find("div")[0].setAttribute('data-check-check', 'check');
        }
      };
      widgets = null;
      return require(['widgets', 'dom', 'events'], function(widgetsModule, domModule, eventsModule) {
        widgets = widgetsModule;
        dom = domModule;
        return events = eventsModule;
      });
    });
    describe("widget initialisation", function() {
      it('should init widget properly: create object, generate id, save instance', function() {
        waitsFor(function() {
          return widgets != null;
        });
        return runs(function() {
          var element, widgetInstance;
          element = dom("div.widget").get(0);
          widgetInstance = new widgets._constructor('sampleWidget', element, sampleWidget);
          expect(widgetInstance.init).toBeFunction();
          expect(widgetInstance.turnOff).toBeFunction();
          expect(widgetInstance.turnOn).toBeFunction();
          expect(widgetInstance.destroy).toBeFunction();
          expect(widgetInstance.anotherEventHandler).toBeFunction();
          expect(widgetInstance.clickHandler).toBeFunction();
          expect(widgetInstance.domEvents).toBeObject();
          expect(widgetInstance.moduleEvents).toBeObject();
          expect(widgetInstance.someProperty).toBe('someProperty');
          expect(widgetInstance.id).toBeDefined();
          expect(widgetInstance.element).toBe(element);
          expect(widgetInstance.isInitialized).toBe(true);
          return expect(widgetInstance._isOn).toBe(true);
        });
      });
      it('should save instance', function() {
        waitsFor(function() {
          return widgets != null;
        });
        return runs(function() {
          var element, widgetInstance;
          element = dom("div.widget").get(0);
          widgetInstance = new widgets._constructor('sampleWidget', element, sampleWidget);
          expect(widgetInstance.element.getAttribute("data-widget-sampleWidget-id")).toBe(widgetInstance.id);
          return expect(widgets._instances[widgetInstance.id]).toBe(widgetInstance);
        });
      });
      return it('should init widget on element only once', function() {
        waitsFor(function() {
          return widgets != null;
        });
        return runs(function() {
          var element, widgetInstance1, widgetInstance2;
          element = dom("div.widget").get(0);
          widgetInstance1 = new widgets._constructor('sampleWidget', element, sampleWidget);
          widgetInstance2 = new widgets._constructor('sampleWidget', element, sampleWidget);
          return expect(widgetInstance1.id).toBe(widgetInstance2.id);
        });
      });
    });
    describe("widget destroying", function() {
      return it('should destroy widget completly', function() {
        waitsFor(function() {
          return widgets != null;
        });
        return runs(function() {
          var element, widgetInstance;
          element = dom("div.widget").get(0);
          widgetInstance = new widgets._constructor('sampleWidget', element, sampleWidget);
          widgetInstance.destroy();
          return expect(widgetInstance).toBeEmpty();
        });
      });
    });
    describe('turning widget off', function() {
      return it('should turn widget off (unbind all event handlers)', function() {
        waitsFor(function() {
          return widgets != null;
        });
        return runs(function() {
          var element, widgetInstance;
          jasmine.Clock.useMock();
          element = dom("div.widget").get(0);
          widgetInstance = new widgets._constructor('sampleWidget', element, sampleWidget);
          widgetInstance.turnOff();
          triggerMouseEvent("click", dom("div.action")[0]);
          triggerMouseEvent("click", dom("div.mouser")[0]);
          events.trigger("sampleEvent", {});
          events.trigger("anotherEvent", {});
          jasmine.Clock.tick(101);
          expect(clickSpy).not.toHaveBeenCalled();
          expect(clickHandlerSpy).not.toHaveBeenCalled();
          expect(sampleEventSpy).not.toHaveBeenCalled();
          return expect(anotherEventHandlerSpy).not.toHaveBeenCalled();
        });
      });
    });
    return describe('turning widget on', function() {
      return it('should turn widget on after it was turned off', function() {
        waitsFor(function() {
          return widgets != null;
        });
        return runs(function() {
          var element, old_delay, widgetInstance;
          old_delay = _.delay;
          _.delay = function(handler, args) {
            return handler.apply(this, args);
          };
          element = dom("div.widget").get(0);
          widgetInstance = new widgets._constructor('sampleWidget', element, sampleWidget);
          widgetInstance.turnOff();
          widgetInstance.turnOn();
          triggerMouseEvent("click", dom("div.action")[0]);
          triggerMouseEvent("click", dom("div.mouser")[0]);
          events.trigger("sampleEvent", {});
          events.trigger("anotherEvent", {});
          _.delay = old_delay;
          expect(clickSpy).toHaveBeenCalled();
          expect(clickHandlerSpy).toHaveBeenCalled();
          expect(sampleEventSpy).toHaveBeenCalled();
          return expect(anotherEventHandlerSpy).toHaveBeenCalled();
        });
      });
    });
  });

}).call(this);
