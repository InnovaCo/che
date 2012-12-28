describe "widgets module", ->
  widgets = null
  dom = null
  events = null
  sampleWidget = null
  clickSpy = null
  sampleEventSpy = null
  clickHandlerSpy = null
  anotherEventHandlerSpy = null

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

    clickSpy = jasmine.createSpy 'clickSpy'
    clickHandlerSpy = jasmine.createSpy 'clickHandlerSpy'
    sampleEventSpy = jasmine.createSpy "sampleEventSpy"
    anotherEventHandlerSpy = jasmine.createSpy "anotherEventHandlerSpy"

    affix("div.widget ul li div.mouser div.action")

    sampleWidget = 
      domEvents:
        "click div.action": clickSpy
        "click div.mouser": "clickHandler"
      clickHandler: clickHandlerSpy
      moduleEvents:
        "sampleEvent": sampleEventSpy
        "anotherEvent": "anotherEventHandler"
      anotherEventHandler: anotherEventHandlerSpy,
      someProperty: "someProperty"

      init: (element) ->
        dom(element).find("div")[0].setAttribute('data-check-check', 'check')

    

    widgets = null
    require ['widgets', 'dom', 'events'], (widgetsModule, domModule, eventsModule) ->
      widgets = widgetsModule
      dom = domModule
      events = eventsModule

  describe "widget initialisation", ->
    it 'should init widget properly: create object, generate id, save instance', ->
      waitsFor ->
        widgets?
      runs ->
        element = dom("div.widget").get(0)
        widgetInstance = new widgets._constructor 'sampleWidget', element, sampleWidget

        expect(widgetInstance.init).toBeFunction()
        expect(widgetInstance.turnOff).toBeFunction()
        expect(widgetInstance.turnOn).toBeFunction()
        expect(widgetInstance.destroy).toBeFunction()
        expect(widgetInstance.anotherEventHandler).toBeFunction()
        expect(widgetInstance.clickHandler).toBeFunction()
        expect(widgetInstance.domEvents).toBeObject()
        expect(widgetInstance.moduleEvents).toBeObject()
        expect(widgetInstance.someProperty).toBe('someProperty')
        expect(widgetInstance.id).toBeDefined()
        expect(widgetInstance.element).toBe(element)
        expect(widgetInstance.isInitialized).toBe(yes)
        expect(widgetInstance._isOn).toBe(yes)

    it 'should save instance', ->
      waitsFor ->
        widgets?
      runs ->
        element = dom("div.widget").get(0)
        widgetInstance = new widgets._constructor 'sampleWidget', element, sampleWidget

        expect(widgetInstance.element.getAttribute "data-sampleWidget-id").toBe(widgetInstance.id)
        expect(widgets._instances[widgetInstance.id]).toBe(widgetInstance)

    it 'should init widget on element only once', ->
      waitsFor ->
        widgets?
      runs ->
        element = dom("div.widget").get(0)
        widgetInstance1 = new widgets._constructor 'sampleWidget', element, sampleWidget
        widgetInstance2 = new widgets._constructor 'sampleWidget', element, sampleWidget
        
        expect(widgetInstance1.id).toBe(widgetInstance2.id)

  describe "widget destroying", ->
    it 'should destroy widget completly', ->
      waitsFor ->
        widgets?
      runs ->
        element = dom("div.widget").get(0)
        widgetInstance = new widgets._constructor 'sampleWidget', element, sampleWidget
        
        widgetInstance.destroy()
        expect(widgetInstance).toBeEmpty()

  describe 'turning widget off', ->
    it 'should turn widget off (unbind all event handlers)', ->
      waitsFor ->
        widgets?
      runs ->
        jasmine.Clock.useMock()
        element = dom("div.widget").get(0)
        widgetInstance = new widgets._constructor 'sampleWidget', element, sampleWidget

        widgetInstance.turnOff()
        
        triggerMouseEvent("click", dom("div.action")[0])
        triggerMouseEvent("click", dom("div.mouser")[0])

        events.trigger("sampleEvent", {})
        events.trigger("anotherEvent", {})

        jasmine.Clock.tick(101)

        expect(clickSpy).not.toHaveBeenCalled()
        expect(clickHandlerSpy).not.toHaveBeenCalled()
        expect(sampleEventSpy).not.toHaveBeenCalled()
        expect(anotherEventHandlerSpy).not.toHaveBeenCalled()

  describe 'turning widget on', ->
    it 'should turn widget on after it was turned off', ->
      waitsFor ->
        widgets?
      runs ->
        
        old_delay = _.delay
        _.delay = (handler, args)->
          handler.apply(this, args)

        element = dom("div.widget").get(0)
        widgetInstance = new widgets._constructor 'sampleWidget', element, sampleWidget

        widgetInstance.turnOff()
        widgetInstance.turnOn()
        
        triggerMouseEvent("click", dom("div.action")[0])
        triggerMouseEvent("click", dom("div.mouser")[0])

        events.trigger("sampleEvent", {})
        events.trigger("anotherEvent", {})

        _.delay = old_delay

        expect(clickSpy).toHaveBeenCalled()
        expect(clickHandlerSpy).toHaveBeenCalled()
        expect(sampleEventSpy).toHaveBeenCalled()
        expect(anotherEventHandlerSpy).toHaveBeenCalled()
