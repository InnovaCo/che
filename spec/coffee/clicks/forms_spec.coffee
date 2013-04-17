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
    triggerMouseEvent = domEvents.triggerMouseEvent

    beforeEach ->
      jasmine.Clock.useMock();
      forms.reset()

    it "should call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      forms ->
        handler arguments

      formNode = affix 'form[data-reload-sections="testData"] input[type="submit"]'
      triggerMouseEvent "click", $(formNode[0]).find("input[type=submit]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).toHaveBeenCalled()
      expect(handler.mostRecentCall.args[0][0]).toBe("")
      expect(handler.mostRecentCall.args[0][1]).toBe("testData")
      expect(handler.mostRecentCall.args[0][2]).toBe("GET")

    it "should call handler with serialized form data, when post form have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      forms ->
        handler arguments

      formNode = affix 'form[data-reload-sections="testData"][method="POST"] input[type="hidden"][value="123"][name="testInput"] input[type=submit]'
      triggerMouseEvent "click", $(formNode[0]).find("input[type=submit]")[0]

      jasmine.Clock.tick(1000);

      expect(handler).toHaveBeenCalled()
      expect(handler.mostRecentCall.args[0][0]).toBe("")
      expect(handler.mostRecentCall.args[0][1]).toBe("testData")
      expect(handler.mostRecentCall.args[0][2]).toBe("POST")
      expect(handler.mostRecentCall.args[0][3]).toBe("testInput=123")

    it "should not call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")
      handlerSubmit = jasmine.createSpy("handlerSubmit").andReturn(false)

      forms ->
        handler arguments

      formNode = affix 'form["data-something-else"] input[type="submit"]'
      $(formNode[0]).submit(handlerSubmit)
      triggerMouseEvent "click", $(formNode[0]).find("input[type=submit]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).not.toHaveBeenCalled()
      expect(handlerSubmit).toHaveBeenCalled()
