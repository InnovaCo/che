describe "preloader  module", -> 
  describe "searching for widgets", ->
    preloader = null
    loadSpy = null
    requireSpy = null

    beforeEach ->
      preloader = null
      for index in [0..9]
        affix 'div.widget[data-js-module="module_' + index + '"]'
      require ["preloader"], (preloaderModule) ->
        requireSpy = spyOn(window, "require").andCallThrough()
        preloader = preloaderModule
        loadSpy = spyOn(preloader, "loadWidgetModule").andCallThrough()
      
    it "should find all widgets on page", ->
      waitsFor ->
        preloader isnt null
      runs ->
        preloader.searchForWidgets()
        expect(loadSpy.calls.length).toEqual(10)
        expect(loadSpy.mostRecentCall.args[0].getAttribute 'data-js-module').toBe('module_9')

    it "should load all found widgets", ->
      waitsFor ->
        preloader isnt null
      runs ->
        preloader.searchForWidgets()
        expect(requireSpy.calls.length).toEqual(10)
        expect(requireSpy.mostRecentCall.args[0][0]).toBe('module_9')
      