describe 'dom module', ->
  dom = null
  triggerMouseEvent = null
  beforeEach ->
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
      affix "div.test ul li a"

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



