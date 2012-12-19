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

  describe 'initialize dom object', ->
    DOMelement = null
    beforeEach ->
      fixture = affix "div.test ul li a#test"
      DOMelement = document.getElementById('test')

    it 'should have "on", "off", "find", "get" functions', ->
      waitsFor ->
        dom?
      runs ->
        domObject = dom("div.test ul li a")
        expect(domObject.on).toBeFunction()
        expect(domObject.off).toBeFunction()
        expect(domObject.find).toBeFunction()
        expect(domObject.get).toBeFunction()

    it 'should return object with DOMelement when called with selector', ->
      waitsFor ->
        dom?
      runs ->
        domObject = dom("div.test ul li a")
        expect(_.isEqual(DOMelement, domObject[0])).toBe(true)
        expect(domObject.length).toBe(1)
        expect(domObject instanceof dom).toBeTruthy()

    it 'should return empty object when called with invalidselector', ->
      waitsFor ->
        dom?
      runs ->
        domObject = dom(".selectorForNoresults")
        expect(domObject.length).toBe(0)
        expect(domObject[0]).toBeUndefined()


  describe 'binding events', ->
    beforeEach ->
      affix "div.test ul li a"

    it 'should bind event handler to element', ->
      waitsFor ->
        dom?
      runs ->
        bindSpy = jasmine.createSpy "bindSpy"
        dom("div.test ul li a").on 'click', bindSpy

        triggerMouseEvent("click", dom("div.test ul li a").get(0))
        expect(bindSpy).toHaveBeenCalled()

    it 'should delegate event handler to element', ->
      waitsFor ->
        dom?
      runs ->
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
      waitsFor ->
        dom?
      runs ->
        bindSpy = jasmine.createSpy "bindSpy"
        dom("div.test ul li a").on 'click', bindSpy
        dom("div.test ul li a").off 'click', bindSpy

        triggerMouseEvent("click", dom("div.test ul li a").get(0))
        

    it 'should delegate event handler to element', ->
      waitsFor ->
        dom?
      runs ->
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
      waitsFor ->
        dom?
      runs ->
        obj = dom('div.test')
        foundObj = obj.find('a#test')
        expect(_.isEqual(foundObj.get(0), DOMelement)).toBeTruthy()
    it 'find should return instance of domQuery', ->
      waitsFor ->
        dom?
      runs ->
        obj = dom('div.test')
        expect(obj instanceof dom).toBeTruthy()

