describe 'dom module', ->
  dom = null
  triggerMouseEvent = domEvents.triggerMouseEvent
  beforeEach ->
    require ['dom'], (domModule) ->
      dom = domModule
    waitsFor ->
      dom?

  describe 'initialize dom object', ->
    DOMelement = null
    beforeEach ->
      fixture = affix "div.test ul li a#test"
      DOMelement = document.getElementById('test')

    it 'should have "on", "off", "find", "get" functions', ->
      
        domObject = dom("div.test ul li a")
        expect(domObject.on).toBeFunction()
        expect(domObject.off).toBeFunction()
        expect(domObject.find).toBeFunction()
        expect(domObject.get).toBeFunction()

    it 'should return object with DOMelement when called with selector', ->
      
        domObject = dom("div.test ul li a")
        expect(_.isEqual(DOMelement, domObject[0])).toBe(true)
        expect(domObject.length).toBe(1)
        expect(domObject instanceof dom).toBeTruthy()

    it 'should return empty object when called with invalidselector', ->
      
        domObject = dom(".selectorForNoresults")
        expect(domObject.length).toBe(0)
        expect(domObject[0]).toBeUndefined()


  describe 'binding events', ->
    beforeEach ->
      affix "a.test"
      affix "div.test a"
      affix "div.test ul a"
      affix "div.test ul li a span"
      affix "span.test ul li a span.test"

    it 'should bind event handler to element', ->
      
      bindSpy = jasmine.createSpy "bindSpy"
      dom("div.test ul li a").on 'click', bindSpy

      triggerMouseEvent("click", dom("div.test ul li a").get(0))
      expect(bindSpy).toHaveBeenCalled()

    it 'should delegate event handler to element', ->
      
      bindSpy = jasmine.createSpy "bindSpy"
      dom("div.test").on 'ul li a', 'click', bindSpy

      triggerMouseEvent("click", dom("div.test ul li a").get(0))
      waitsFor ->
        0 < bindSpy.calls.length
      runs ->
        expect(bindSpy).toHaveBeenCalled()

    it 'should delegate event handler to element from body', ->
      
      bindSpy = jasmine.createSpy "bindSpy"
      dom("body").on 'a', 'click', bindSpy

      triggerMouseEvent("click", dom("div.test ul li a").get(0))
      expect(bindSpy).toHaveBeenCalled()

    it 'should delegate event handler to element from body, when several elements on page', ->
      
      bindSpy = jasmine.createSpy "bindSpy"
      dom("body").on 'a', 'click', bindSpy

      triggerMouseEvent("click", dom("div.test ul li a").get(0))
      expect(bindSpy).toHaveBeenCalled()

    it 'should delegate event handler to element, when event triggered on element inside of selector matched element', ->
      bindSpy = jasmine.createSpy "bindSpy"
      dom("div.test").on 'ul li a', 'click', bindSpy

      triggerMouseEvent("click", dom("div.test ul li a span").get(0))
      expect(bindSpy).toHaveBeenCalled()

    it 'should return correct target to event handler, when event triggered on element inside of selector matched element', ->
      bindSpy = jasmine.createSpy "bindSpy"
      target = null
      original = dom("div.test ul li a").get 0
      dom("div.test").on 'ul li a', 'click', () ->        
        target = @
        bindSpy()

      
      triggerMouseEvent("click", dom("div.test ul li a span").get(0))
      console.log target, original
      expect(target).toBe original

    it 'shouldn\'t delegate event handler to element, when event triggered on parent of root', ->

      bindSpy = jasmine.createSpy "bindSpy"
      dom("div.test ul").on 'ul li a', 'click', bindSpy

      triggerMouseEvent("click", dom("div.test").get(0))
      expect(bindSpy).not.toHaveBeenCalled()

    it 'shouldn\'t delegate event handler to element, when event triggered on parent of root and globally matches selector', ->

      bindSpy = jasmine.createSpy "bindSpy"
      dom("span.test ul").on 'span.test', 'click', bindSpy

      triggerMouseEvent("click", dom("span.test").get(0))
      expect(bindSpy).not.toHaveBeenCalled()
        

  describe 'unbinding events', ->
    beforeEach ->
      affix "div.test ul li a"

    it 'should bind and unbind event handler to element', ->
      
        bindSpy = jasmine.createSpy "bindSpy"
        dom("div.test ul li a").on 'click', bindSpy
        dom("div.test ul li a").off 'click', bindSpy

        triggerMouseEvent("click", dom("div.test ul li a").get(0))
        expect(bindSpy).not.toHaveBeenCalled()
        
    it 'should delegate event handler to element', ->
      
        bindSpy = jasmine.createSpy "bindSpy"
        dom("div.test").on 'ul li a', 'click', bindSpy
        dom("div.test").off 'ul li a', 'click', bindSpy

        triggerMouseEvent("click", dom("div.test ul li a").get(0))
        expect(bindSpy).not.toHaveBeenCalled()

  describe 'finding objects', ->
    DOMelement = null
    beforeEach ->
      fixture = affix "div.test ul li a#test"
      DOMelement = document.getElementById('test')
    it 'should find element inside', ->
        obj = dom('div.test')
        foundObj = obj.find('a#test')
        expect(_.isEqual(foundObj.get(0), DOMelement)).toBeTruthy()
    it 'find should return instance of domQuery', ->
        obj = dom('div.test')
        expect(obj instanceof dom).toBeTruthy()


  describe 'loader API', ->
    
    domReady = null
    beforeEach ->
      domReady = null
      require ['lib/domReady'], (domReadyModule) ->
        domReady = domReadyModule

      waitsFor ->
        domReady isnt null

    it 'should call return dom module, when required as loader', ->
      module = null
      require ['dom!'], (dom) ->
        module = dom

      waitsFor ->
        module?
      runs ->
        expect(module).toBe dom

    it 'should call onload with null in build mode', ->
      onload = jasmine.createSpy 'onload'
      dom.load "onload", null, onload,
        isBuild: true

      expect(onload).toHaveBeenCalled()
      expect(onload.mostRecentCall.args[0]).toBe(dom)



