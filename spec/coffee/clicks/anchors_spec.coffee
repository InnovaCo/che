describe "clicks/anchors module", ->
  anchors = null

  require [
    'clicks/anchors'
    ], (anchorsModule) ->
    anchors = anchorsModule

  waitsFor ->
    anchors?

  beforeEach ->
    anchors.reset()

  describe "anchor clicking", ->
    triggerMouseEvent = domEvents.triggerMouseEvent

    beforeEach ->
      jasmine.Clock.useMock()

      anchors.reset()
      affix "a[data-reload-sections='testData']"
      affix "a[data-something-else]"

    it "should call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      anchors ->
        handler arguments

      triggerMouseEvent "click", $("a[data-reload-sections]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).toHaveBeenCalled()
      expect(handler.mostRecentCall.args[0][0]).toBe(null)
      expect(handler.mostRecentCall.args[0][1]).toBe("'testData'")
      expect(handler.mostRecentCall.args[0][2]).toBe("GET")

    it "should not call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      anchors ->
        handler arguments

      triggerMouseEvent "click", $("a[data-something-else]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).not.toHaveBeenCalled()

