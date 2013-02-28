describe "clicks/forms module", ->
  forms = null

  require [
    'clicks/forms'
    ], (formsModule) ->
    forms = formsModule

  waitsFor ->
    forms?

  beforeEach ->
    forms.reset()

  describe "forms clicking", ->
    triggerMouseEvent = null

    beforeEach ->
      jasmine.Clock.useMock();
      triggerMouseEvent = (eventName, element) ->
        if document.createEvent
          event = document.createEvent "MouseEvents"
          event.initEvent eventName, true, true
        else 
          event = document.createEventObject()
          event.eventType = eventName;

        event.eventName = eventName;
        event.memo = {};

        if document.createEvent
          element.dispatchEvent event
        else
          element.fireEvent "on" + event.eventType, event

      forms.reset()
      affix "form[data-reload-sections=testData] input[type=submit]"
      affix "form[data-something-else] input[type=submit]"

    it "should call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")      

      forms ->
        handler arguments

      triggerMouseEvent "click", $("form[data-reload-sections='testData'] input[type='submit']")[0]

      jasmine.Clock.tick(1000);

      expect(handler).toHaveBeenCalled()
      expect(handler.mostRecentCall.args[0][0]).toBe("")
      expect(handler.mostRecentCall.args[0][1]).toBe("testData")
      expect(handler.mostRecentCall.args[0][2]).toBe("GET")

    it "should not call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")      

      forms ->
        handler arguments

      triggerMouseEvent "click", $("form[data-something-else]")[0]

      jasmine.Clock.tick(1000);

      expect(handler).not.toHaveBeenCalled()
        
