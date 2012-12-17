describe 'htmlParser module', ->
  describe 'creating dom elements from plain html text', ->

  describe 'creating array of pairs', ->
    parser = null

    beforeEach ->
      parser = null
      require ["htmlParser"], (parserModule) ->
        parser = parserModule

    it 'should fill array with one pair', ->
      waitsFor ->
        parser isnt null
      runs ->
        arrayOfPairs = []
        domElement = document.createElement("DIV")
        domElement.setAttribute('data-js-module', 'someModule')
        parser._save arrayOfPairs, domElement

        expect(arrayOfPairs.length).toBe 1
        expect(arrayOfPairs[0].name).toBe 'someModule'
        expect(arrayOfPairs[0].element).toEqual domElement

    it 'should fill array with two pairs, modules names in data-attribute are splitted by one comma', ->
      waitsFor ->
        parser isnt null
      runs ->
        arrayOfPairs = []
        domElement = document.createElement("DIV")
        domElement.setAttribute('data-js-module', 'someModule,otherModule')
        parser._save arrayOfPairs, domElement
        
        expect(arrayOfPairs.length).toBe 2
        expect(arrayOfPairs[0].name).toBe 'someModule'
        expect(arrayOfPairs[1].name).toBe 'otherModule'
        expect(arrayOfPairs[0].element).toEqual domElement
        expect(arrayOfPairs[1].element).toEqual domElement

    it 'should fill array with two pairs, modules names in data-attribute are splitted by one comma and space', ->
      waitsFor ->
        parser isnt null
      runs ->
        arrayOfPairs = []
        domElement = document.createElement("DIV")
        domElement.setAttribute('data-js-module', 'someModule, otherModule')
        parser._save arrayOfPairs, domElement
        
        expect(arrayOfPairs.length).toBe 2
        expect(arrayOfPairs[0].name).toBe 'someModule'
        expect(arrayOfPairs[1].name).toBe 'otherModule'
        expect(arrayOfPairs[0].element).toEqual domElement
        expect(arrayOfPairs[1].element).toEqual domElement

    it 'should fill array with two pairs, in each pair module name should be the same', ->
      waitsFor ->
        parser isnt null
      runs ->
        arrayOfPairs = []
        domElement = document.createElement("DIV")
        domElement.setAttribute('data-js-module', 'someModule')
        domElement2 = document.createElement("DIV")
        domElement2.setAttribute('data-js-module', 'someModule')

        parser._save arrayOfPairs, domElement
        parser._save arrayOfPairs, domElement2
        
        expect(arrayOfPairs.length).toBe 2
        expect(arrayOfPairs[0].name).toBe 'someModule'
        expect(arrayOfPairs[1].name).toBe 'someModule'
        expect(arrayOfPairs[0].element).toEqual domElement
        expect(arrayOfPairs[1].element).toEqual domElement2

  describe 'searching for modules', ->
    parser = null

    beforeEach ->
      parser = null
      for index in [0...3]
        affix 'div.widget[data-js-module="module_' + index + '"]'

      for index in [0...3]
        affix 'div.widget[data-js-module="module_fisrt_' + index + ',
        module_second_' + index + '"]'

      for index in [0...3]
        affix 'div.widget[data-js-module="module_first_' + index + ',
        module_second_' + index + ', module_thrird_' + index + ' "]'

      require ["htmlParser"], (parserModule) ->
        parser = parserModule


    it 'should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in dom node', ->
      waitsFor ->
        parser isnt null
      runs ->
        pairs = parser $('body')[0]
        modulesNames = _.pluck pairs, "name"
        expect(pairs.length).toBe 18
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
        parser isnt null
      runs ->
        pairs = parser $('body').html()
        modulesNames = _.pluck pairs, "name"
        expect(pairs.length).toBe 18
        expect(modulesNames).toContain "module_0"
        expect(modulesNames).toContain "module_2"
        expect(modulesNames).toContain "module_first_0"
        expect(modulesNames).toContain "module_first_1"
        expect(modulesNames).toContain "module_second_0"
        expect(modulesNames).toContain "module_second_2"
        expect(modulesNames).toContain "module_thrird_0"
        expect(modulesNames).toContain "module_thrird_2"
      
