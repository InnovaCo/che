(function() {

  describe("widgets module", function() {
    var anotherEventHandlerSpy, clickSpy, sampleEventSpy, sampleWidget;
    sampleWidget = null;
    clickSpy = null;
    sampleEventSpy = null;
    anotherEventHandlerSpy = null;
    beforeEach(function() {
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
        anotherEventHandler: anotherEventHandlerSpy,
        init: function(element) {
          return dom(element).find("a").setAttribute('href', '');
        }
      };
      return affix('div a.action').append('');
    });
    describe("widget with events initialisation", function() {});
    describe('turning widget off', function() {});
    describe('turning widget on', function() {});
    return describe('destroy widget', function() {});
  });

}).call(this);
