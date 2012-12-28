describe "loader  module", -> 
  describe "searching for widgets", ->
    loader = null
    loadSpy = null
    requireSpy = null

    beforeEach ->
      loader = null
      for index in [0..9]
        affix 'div.widget[data-js-modules="module_' + index + '"]'
      require ["loader"], (preloaderModule) ->
        requireSpy = spyOn(window, "require").andCallThrough()
        loader = preloaderModule
        loadSpy = spyOn(loader, "loadWidgetModule").andCallThrough()
      
    it "should find all widgets on page", ->
      waitsFor ->
        loader isnt null
      runs ->
        loader.searchForWidgets()
        expect(loadSpy.calls.length).toEqual(10)
        expect(loadSpy.mostRecentCall.args[0].name).toBe('module_9')

    it "should load all found widgets", ->
      waitsFor ->
        loader isnt null
      runs ->
        loader.searchForWidgets()
        expect(requireSpy.calls.length).toEqual(10)
        expect(requireSpy.mostRecentCall.args[0][0]).toBe('widgets/module_9')
      