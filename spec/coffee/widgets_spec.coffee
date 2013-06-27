describe "widgets module", ->
  widgets = null
  dom = null
  events = null
  sampleWidget = null
  clickSpy = null
  clickSpyRoot = null
  clickSpyMouseover = null
  sampleEventSpy = null
  clickHandlerSpy = null
  anotherEventHandlerSpy = null

  triggerMouseEvent = domEvents.triggerMouseEvent

  beforeEach ->
    clickSpy = jasmine.createSpy 'clickSpy'
    clickSpyRoot = jasmine.createSpy 'clickSpyRoot'
    clickSpyMouseover = jasmine.createSpy 'clickSpyMouseover'
    clickHandlerSpy = jasmine.createSpy 'clickHandlerSpy'
    sampleEventSpy = jasmine.createSpy "sampleEventSpy"
    anotherEventHandlerSpy = jasmine.createSpy "anotherEventHandlerSpy"

    affix("div.widget ul li div.mouser div.action")

    sampleWidget =
      domEvents:
        "click div.action": clickSpy
        "click div.mouser": "clickHandler"
        "click @element": clickSpyRoot
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

      triggerMouseEvent "click", dom("div.action")[0]
      triggerMouseEvent "click", dom("div.mouser")[0]

      events.trigger "sampleEvent"
      events.trigger "anotherEvent"

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

    it 'should turn widget on and trigger events on root element', ->
      jasmine.Clock.useMock()

      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'sampleWidget', element, sampleWidget

      triggerMouseEvent("click", dom("div.widget")[0])

      jasmine.Clock.tick(101)

      expect(clickSpyRoot).toHaveBeenCalled()

    it "should call handlers from moduleEvents if such events fired before, when using 'recall' flag", ->
      jasmine.Clock.useMock()
      testValue = 0

      events.trigger "oldEvent" # сразу файрим событие.

      jasmine.Clock.tick(101)

      checkWidget =
        moduleEvents:
          "oldEvent":
            handler: "oldEventHandler"
            recall: true
        oldEventHandler: ->
          testValue++

      spyOn(checkWidget, "oldEventHandler").andCallThrough()

      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'checkWidget', element, checkWidget

      jasmine.Clock.tick(101)

      runs ->
        expect(checkWidget.oldEventHandler).toHaveBeenCalled()
        expect(checkWidget.oldEventHandler.calls.length).toBe 1
        expect(testValue).toBe 1


  describe 'many similar widgets on page', ->
    it 'should call their methods exactly in their own context via moduleEvents', ->
      jasmine.Clock.useMock()
      affix("div.widget2 ul li div.mouser div.action")

      checkWidget =
        moduleEvents:
          "check-many-widgets": "manyWidgetsCheck"
        manyWidgetsCheck: ->
          @element.setAttribute "data-test-many-widgets", "yes"

      spyOn(checkWidget, "manyWidgetsCheck").andCallThrough()


      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'checkWidget', element, checkWidget

      element2 = dom("div.widget2").get(0)
      widgetInstance2 = widgets._manager.add 'checkWidget', element2, checkWidget

      events.trigger "check-many-widgets"

      jasmine.Clock.tick(101)

      runs ->
        expect(checkWidget.manyWidgetsCheck).toHaveBeenCalled()
        expect(checkWidget.manyWidgetsCheck.calls.length).toBe 2
        expect( dom("div.widget")[0].getAttribute "data-test-many-widgets" ).toBe "yes"
        expect( dom("div.widget2")[0].getAttribute "data-test-many-widgets" ).toBe "yes"

    it 'should call method only on first widget when click on element inside first container via domEvents', ->
      jasmine.Clock.useMock()
      affix("div.widget2 ul li div.mouser div.action")

      checkWidget =
        domEvents:
          "click .mouser": "manyWidgetsCheck"
        manyWidgetsCheck: ->
          @element.setAttribute "data-test-many-widgets", "yes"

      spyOn(checkWidget, "manyWidgetsCheck").andCallThrough()


      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'checkWidget', element, checkWidget

      element2 = dom("div.widget2").get(0)
      widgetInstance2 = widgets._manager.add 'checkWidget', element2, checkWidget

      triggerMouseEvent("click", dom("div.widget div.mouser")[0])

      jasmine.Clock.tick(101)

      runs ->
        expect(checkWidget.manyWidgetsCheck).toHaveBeenCalled()
        expect(checkWidget.manyWidgetsCheck.calls.length).toBe 1
        expect( dom("div.widget")[0].getAttribute "data-test-many-widgets" ).toBe "yes"
        expect( dom("div.widget2")[0].getAttribute "data-test-many-widgets" ).toBe null

    it 'should call method only on second widget when click on element inside second container via domEvents', ->
      jasmine.Clock.useMock()
      affix("div.widget2 ul li div.mouser.mouser2 div.action")

      checkWidget =
        domEvents:
          "click .mouser": "manyWidgetsCheck"
        manyWidgetsCheck: ->
          @element.setAttribute "data-test-many-widgets", "yes"

      spyOn(checkWidget, "manyWidgetsCheck").andCallThrough()


      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'checkWidget', element, checkWidget

      element2 = dom("div.widget2").get(0)
      widgetInstance2 = widgets._manager.add 'checkWidget', element2, checkWidget

      triggerMouseEvent("click", dom("div.widget2 div.mouser")[0])

      jasmine.Clock.tick(101)

      runs ->
        expect(checkWidget.manyWidgetsCheck).toHaveBeenCalled()
        expect(checkWidget.manyWidgetsCheck.calls.length).toBe 1
        expect( dom("div.widget")[0].getAttribute "data-test-many-widgets" ).toBe null
        expect( dom("div.widget2")[0].getAttribute "data-test-many-widgets" ).toBe "yes"


    it "turning off one widget should'nt turn off another one", ->
      jasmine.Clock.useMock()
      affix("div.widget2 ul li div.mouser.mouser2 div.action")

      checkWidget =
        domEvents:
          "click .mouser": "manyWidgetsCheck"
        manyWidgetsCheck: ->
          @element.setAttribute "data-test-many-widgets", "yes"

      spyOn(checkWidget, "manyWidgetsCheck").andCallThrough()

      element = dom("div.widget").get(0)
      widgetInstance = widgets._manager.add 'checkWidget', element, checkWidget

      element2 = dom("div.widget2").get(0)
      widgetInstance2 = widgets._manager.add 'checkWidget', element2, checkWidget

      widgetInstance.sleepDown()

      triggerMouseEvent("click", dom("div.widget div.mouser")[0])
      triggerMouseEvent("click", dom("div.widget2 div.mouser")[0])
      jasmine.Clock.tick(101)

      runs ->
        expect(checkWidget.manyWidgetsCheck).toHaveBeenCalled()
        expect(checkWidget.manyWidgetsCheck.calls.length).toBe 1
        expect( dom("div.widget")[0].getAttribute "data-test-many-widgets" ).toBe null
        expect( dom("div.widget2")[0].getAttribute "data-test-many-widgets" ).toBe "yes"



