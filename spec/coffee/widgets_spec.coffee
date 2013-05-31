describe "widgets module", ->
  widgets = null
  dom = null
  events = null
  sampleWidget = null
  clickSpy = null
  clickSpyMouseover = null
  sampleEventSpy = null
  clickHandlerSpy = null
  anotherEventHandlerSpy = null

  triggerMouseEvent = domEvents.triggerMouseEvent

  beforeEach ->
    clickSpy = jasmine.createSpy 'clickSpy'
    clickSpyMouseover = jasmine.createSpy 'clickSpyMouseover'
    clickHandlerSpy = jasmine.createSpy 'clickHandlerSpy'
    sampleEventSpy = jasmine.createSpy "sampleEventSpy"
    anotherEventHandlerSpy = jasmine.createSpy "anotherEventHandlerSpy"

    affix("div.widget ul li div.mouser div.action")

    sampleWidget =
      domEvents:
        "click div.action": clickSpy
        "click div.mouser": "clickHandler"
        "mouseover div.mouser": clickSpyMouseover
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

    waitsFor ->
      widgets?

  describe "widget initialisation", ->
    it 'should init widget properly: create object, generate id, save instance', ->
      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add  'sampleWidget', element, sampleWidget

      expect(widgetInstance.init).toBeFunction()
      expect(widgetInstance.sleepDown).toBeFunction()
      expect(widgetInstance.wakeUp).toBeFunction()
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

    it 'should init versioned widget', ->
      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'sampleWidget?sd=sd', element, sampleWidget

      expect(widgetInstance.init).toBeFunction()

    it 'should save instance', ->
      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'sampleWidget', element, sampleWidget

      expect(widgetInstance.element.getAttribute "data-sampleWidget-id").toBe(widgetInstance.id)
      expect(widgets._manager._instances[widgetInstance.id]).toBe(widgetInstance)

    it 'should init widget on element only once', ->
      element = dom("div.widget").get(0)
      widgetInstance1 = widgets._manager.add 'sampleWidget', element, sampleWidget
      widgetInstance2 = widgets._manager.add  'sampleWidget', element, sampleWidget

      expect(widgetInstance1.id).toBe(widgetInstance2.id)

  describe "widget destroying", ->
    it 'should destroy widget completly', ->
      element = dom("div.widget").get(0)
      widgetInstance = new widgets._constructor 'sampleWidget', element, sampleWidget

      widgetInstance.destroy()
      expect(widgetInstance).toBeEmpty()

  describe 'turning widget off', ->
    it 'should turn widget off (unbind all event handlers)', ->
      jasmine.Clock.useMock()
      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'sampleWidget', element, sampleWidget

      widgetInstance.sleepDown()

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
      jasmine.Clock.useMock()

      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'sampleWidget', element, sampleWidget

      widgetInstance.sleepDown()
      widgetInstance.wakeUp()

      triggerMouseEvent("click", dom("div.action")[0])
      triggerMouseEvent("click", dom("div.mouser")[0])
      triggerMouseEvent("mouseover", dom("div.mouser")[0])

      events.trigger("sampleEvent", {})
      events.trigger("anotherEvent", {})

      jasmine.Clock.tick(101)

      expect(clickSpy).toHaveBeenCalled()
      expect(clickSpyMouseover).toHaveBeenCalled()
      expect(clickHandlerSpy).toHaveBeenCalled()
      expect(sampleEventSpy).toHaveBeenCalled()
      expect(anotherEventHandlerSpy).toHaveBeenCalled()

    it 'should turn widget on and trigger events on form element', ->
      jasmine.Clock.useMock()

      affix("form.widget ul li div.mouser div.action input")
      element = dom("form.widget").get(0)
      widgetInstance = widgets._manager.add 'sampleWidget', element, sampleWidget

      triggerMouseEvent("click", dom("form.widget div.action")[0])
      triggerMouseEvent("click", dom("form.widget div.mouser")[0])

      jasmine.Clock.tick(101)

      expect(clickSpy).toHaveBeenCalled()
      expect(clickHandlerSpy).toHaveBeenCalled()