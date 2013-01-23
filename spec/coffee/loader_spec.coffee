describe "loader  module", -> 
  loader = null
  loadSpy = null
  requireSpy = null

  beforeEach ->
    loader = null
    require ["loader"], (preloaderModule) ->
      loader = preloaderModule

  describe "searching for widgets", ->

    beforeEach ->
      for index in [0..9]
        affix 'div.widget[data-js-modules="module_' + index + '"]'
      require ["loader"], (preloaderModule) ->
        requireSpy = spyOn(window, "require").andCallThrough()
        loadSpy = spyOn(loader, "widgets").andCallThrough()
      
    it "should find all widgets on page", ->
      waitsFor ->
        loader isnt null
      runs ->
        loader.search()
        expect(loadSpy.calls.length).toEqual(1)
        expect(loadSpy.mostRecentCall.args[0][9].name).toBe('module_9')

    it "should load all found widgets", ->
      waitsFor ->
        loader isnt null
      runs ->
        loader.search()
        expect(requireSpy.calls.length).toEqual(10)
        expect(requireSpy.mostRecentCall.args[0][0]).toBe('widgets/module_9')


  describe 'searching for modules data', ->
    beforeEach ->
      parser = null
      for index in [0...3]
        affix 'div.widget[data-js-modules="module_' + index + '"]'

      for index in [0...3]
        affix 'div.widget[data-js-modules="module_fisrt_' + index + ',
        module_second_' + index + '"]'

      for index in [0...3]
        affix 'div.widget[data-js-modules="module_first_' + index + ',
        module_second_' + index + ', module_thrird_' + index + ' "]'



    it 'should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in dom node', ->
      waitsFor ->
        loader isnt null
      runs ->
        loadSpy = spyOn(loader, "widgets").andCallThrough()
        loader.search $('body')[0]

        modulesNames = _.pluck loadSpy.mostRecentCall.args[0], "name"

        expect(modulesNames.length).toBe 18
        expect(modulesNames).toContain "module_0"
        expect(modulesNames).toContain "module_2"
        expect(modulesNames).toContain "module_first_0"
        expect(modulesNames).toContain 'module_first_1'
        expect(modulesNames).toContain "module_second_0"
        expect(modulesNames).toContain "module_second_2"
        expect(modulesNames).toContain "module_thrird_0"
        expect(modulesNames).toContain "module_thrird_2"

    it 'should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in plain HTML text', ->
      waitsFor ->
        loader isnt null
      runs ->
        loadSpy = spyOn(loader, "widgets").andCallThrough()
        loader.search $('body').html()

        modulesNames = _.pluck loadSpy.mostRecentCall.args[0], "name"

        expect(modulesNames.length).toBe 18
        expect(modulesNames).toContain "module_0"
        expect(modulesNames).toContain "module_2"
        expect(modulesNames).toContain "module_first_0"
        expect(modulesNames).toContain "module_first_1"
        expect(modulesNames).toContain "module_second_0"
        expect(modulesNames).toContain "module_second_2"
        expect(modulesNames).toContain "module_thrird_0"
        expect(modulesNames).toContain "module_thrird_2"
      