describe "clicks/forms module", ->
  forms = null

  require ['che!clicks/forms'], (formsModule) ->
    forms = formsModule

  waitsFor ->
    forms?

  beforeEach ->
    forms.reset()

  describe "forms clicking", ->
    triggerMouseEvent = domEvents.triggerMouseEvent

    beforeEach ->
      jasmine.Clock.useMock()
      forms.reset()

    it "should call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      forms ->
        handler arguments

      formNode = affix 'form[data-reload-sections="testData"] input[type="submit"]'
      triggerMouseEvent "click", $(formNode[0]).find("input[type=submit]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).toHaveBeenCalled()
      handlerCall = handler.mostRecentCall.args[0][0]
      expect(handlerCall.url).toBe("")
      expect(handlerCall.data).toBe("testData")
      expect(handlerCall.method).toBe("GET")

    it "should call handler, when submit form with reload sections params", ->
      handler = jasmine.createSpy("handler")

      forms ->
        handler arguments

      formNode = affix 'form[data-reload-sections="testData"]'
      forms.processForms()
      console.log formNode
      $(formNode[0]).submit()

      jasmine.Clock.tick(1000)

      expect(handler).toHaveBeenCalled()
      handlerCall = handler.mostRecentCall.args[0][0]
      expect(handlerCall.url).toBe("")
      expect(handlerCall.data).toBe("testData")
      expect(handlerCall.method).toBe("GET")

    it "should call handler with serialized form data, when post form have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      forms ->
        handler arguments

      formNode = affix 'form[data-reload-sections="testData"][method="POST"][action="/test"] input[type="hidden"][value="123"][name="testInput"] input[type=submit]'
      triggerMouseEvent "click", $(formNode[0]).find("input[type=submit]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).toHaveBeenCalled()
      handlerCall = handler.mostRecentCall.args[0][0]
      expect(handlerCall.url).toBe("/test")
      expect(handlerCall.data).toBe("testData")
      expect(handlerCall.method).toBe("POST")
      expect(handlerCall.formData).toBe("testInput=123")

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

    it "should call handler with correct formed serialized data, when post form with disabled elements", ->
      handler = jasmine.createSpy("handler")

      forms ->
        handler arguments

      formNode = affix 'form[data-reload-sections="testData"][method="POST"][action="/test"] input[type="hidden"][value="999"][name="disabledInput"][disabled="disabled"] input[type="hidden"][value="123"][name="testInput"] input[type=submit]'
      triggerMouseEvent "click", $(formNode[0]).find("input[type=submit]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).toHaveBeenCalled()
      handlerCall = handler.mostRecentCall.args[0][0]
      expect(handlerCall.url).toBe("/test")
      expect(handlerCall.data).toBe("testData")
      expect(handlerCall.method).toBe("POST")
      expect(handlerCall.formData).toBe("testInput=123")
