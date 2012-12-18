(function() {

  describe("widgets module", function() {
    return describe("widget with events initialisation", function() {
      var anotherEventHandlerSpy, clickSpy, sampleEventSpy, sampleWidget;
      sampleWidget = null;
      clickSpy = null;
      sampleEventSpy = null;
      anotherEventHandlerSpy = null;
      return beforeEach(function() {
        var mouseOverHandler;
        clickSpy = jasmine.createSpy('clickSpy');
        mouseOverHandler = jasmine.createSpy('mouseOverHandler');
        sampleEventSpy = jasmine.createSpy("sampleEventSpy");
        anotherEventHandlerSpy = jasmine.createSpy("anotherEventHandlerSpy");
        sampleWidget = {
          domEvents: {
            "click a.action": clickSpy,
            "mouseover div.mouser": "mouseOverHandler"
          },
          mouseOverHandler: mouseOverHandlerSpy,
          moduleEvents: {
            "sampleEvent": sampleEventSpy,
            "anotherEvent": "anotherEventHandler"
          },
          anotherEventHandler: anotherEventHandlerSpy
        };
        return affix('div a.action').append('');
      });
    });
  });

}).call(this);
