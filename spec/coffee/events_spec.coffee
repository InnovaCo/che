describe "events module", ->
  describe "check interface", ->
    events = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events.list = {}

    it "should contain 'once', 'bind', 'unbind', 'trigger', 'create' functions", ->
      waitsFor ->
        events isnt null
      runs ->
        expect(events.create).toBeFunction()
        expect(events.once).toBeFunction()
        expect(events.bind).toBeFunction()
        expect(events.unbind).toBeFunction()
        expect(events.trigger).toBeFunction()

  describe "creating new Event", ->
    events = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events.list = {}
    it "events.create should return CustomEvent", ->
      waitsFor ->
        events isnt null
      runs ->
        CustomEvent = events.create "testEvent"
        expect(CustomEvent).toBeObject()
        expect(CustomEvent.name).toBe "testEvent"
        expect(CustomEvent._handlers).toBeEmpty()

  describe "binding handlers to events", ->
    events = null
    bindSpy = null
    onceSpy = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events.list = {}
        bindSpy = spyOn(events, "bind").andCallThrough()
        onceSpy = spyOn(events, "once").andCallThrough()

    it "should bind handler", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = ->
        testEvent = events.bind "bindTestEvent", handler, {}
        expect(handler.id).toBeDefined()
        expect(events.list['bindTestEvent']._handlers).toBeDefined()
        expect(events.list['bindTestEvent']._handlers[handler.id].options).toBeDefined()
        expect(events.list['bindTestEvent']._handlers[handler.id].id).toBe(handler.id)

    it "should unbind handler", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = ->
        events.bind "testEvent", handler, {}
        expect(events.list['testEvent']._handlers[handler.id].id).toBe(handler.id)
        events.unbind "testEvent", handler
        expect(events.list['testEvent']._handlers[handler.id]).not.toBeDefined()

    it "should call handler after binding (recall option is true)", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = jasmine.createSpy("handler")

        events.trigger 'testEvent',
          testData: 'testData'

        events.bind "testEvent", handler, {},
          isSync: true # to call handler syncronously, tests for isSync option are coming separately
          recall: true

        expect(handler).toHaveBeenCalled()

    it "shouldn't call handler after binding (recall option is false)", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = jasmine.createSpy("handler")

        events.trigger 'testEvent',
          testData: 'testData'

        events.bind "testEvent", handler, {},
          isSync: true # to call handler syncronously, tests for isSync option are coming separately

        expect(handler).not.toHaveBeenCalled()

    it "should bind handler only once", ->
      waitsFor ->
        events isnt null
      runs ->
        handlerI = false
        handler = jasmine.createSpy("handler").andCallFake ->
          handlerIsCalled = true

        events.once 'testEvent', handler, {},
          isSync: true # to call handler syncronously, tests for isSync option are coming separately

        expect(handler).not.toHaveBeenCalled()

        # calling event twice
        events.trigger 'testEvent',
          testData: 'testData'

        expect(handler).toHaveBeenCalled()

        events.trigger 'testEvent',
          testData: 'testData'

        expect(handler.calls.length).not.toBeGreaterThan(1)
  describe "binding handler to compound events", ->
    events = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events.list = {}

    it "should call handler after calling all events from list", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = jasmine.createSpy("compoundHandler")

        events.bind "one, two, three", handler, {},
          isSync: true

        events.trigger 'one',
          data: "one"

        expect(handler).not.toHaveBeenCalled()

        events.trigger 'two',
          data: "two"

        expect(handler).not.toHaveBeenCalled()

        events.trigger 'three',
          data: "three"

        expect(handler).toHaveBeenCalled()
        expect(handler.calls.length).toBe(1)
        expect(handler.mostRecentCall.args[0]).toEqual
          one:
            0:
              data: 'one'
            1:
              name: 'one'
          two:
            0:
              data : 'two'
            1:
              name : 'two'
          three:
            0:
              data: 'three'
            1:
              name: 'three'

    it "should call handler every time after calling all events from list", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = jasmine.createSpy("compoundHandler")

        events.bind "one, two, three", handler, {},
          isSync: true

        events.trigger 'one',
          data: "one"

        expect(handler).not.toHaveBeenCalled()

        events.trigger 'two',
          data: "two"

        expect(handler).not.toHaveBeenCalled()

        events.trigger 'three',
          data: "three"

        expect(handler).toHaveBeenCalled()
        expect(handler.calls.length).toBe(1)

        events.trigger 'one',
          data: "one"

        events.trigger 'two',
          data: "two"


        expect(handler.calls.length).toBe(1)

        events.trigger 'one',
          data: "one"

        events.trigger 'two',
          data: "two"

        events.trigger 'three',
          data: "three"

        expect(handler.calls.length).toBe(2)

        events.trigger 'one',
          data: "one"

        events.trigger 'two',
          data: "two"

        events.trigger 'three',
          data: "three"

        expect(handler.calls.length).toBe(3)

        events.trigger 'three',
          data: "three"

        expect(handler.calls.length).toBe(3)



  describe "calling handlers", ->
    events = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events.list = {}

    it "should call handler syncronously (isSync option is true)", ->
      waitsFor ->
        events isnt null
      runs ->
        syncHandler = jasmine.createSpy("syncHandler")

        events.bind "testEvent", syncHandler, {},
          isSync: true

        events.trigger 'testEvent',
          testData: 'testData'

        expect(syncHandler).toHaveBeenCalled()

    it "should call handler asyncronously (isSync option is false)", ->
      waitsFor ->
        events isnt null
      runs ->
        asyncHandler = jasmine.createSpy("asyncHandler")

        events.bind "testEvent", asyncHandler

        events.trigger 'testEvent',
          testData: 'testData'

        expect(asyncHandler).not.toHaveBeenCalled()

        waitsFor ->
          0 < asyncHandler.calls.length

        runs ->
          expect(asyncHandler).toHaveBeenCalled()

  describe "triggering events", ->
    events = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events.list = {}

    it "should call handlers after triggering event", ->
      waitsFor ->
        events isnt null
      runs ->
        handlers = []
        handlers.push jasmine.createSpy("handler_1")
        handlers.push jasmine.createSpy("handler_2")
        handlers.push jasmine.createSpy("handler_3")
        handlers.push jasmine.createSpy("handler_4")
        handlers.push jasmine.createSpy("handler_5")

        bind = (handler) ->
          events.bind "testEvent", handler, {},
            isSync: true

        bind handler for handler in handlers

        events.trigger "testEvent", 
          testData: "testData"

        expect(handlers[0]).toHaveBeenCalled()
        expect(handlers[1]).toHaveBeenCalled()
        expect(handlers[2]).toHaveBeenCalled()
        expect(handlers[3]).toHaveBeenCalled()
        expect(handlers[4]).toHaveBeenCalled()

    it "should save last event data", ->
      waitsFor ->
        events isnt null
      runs ->
        expect(events.list['testEvent']).not.toBeDefined()

        events.trigger "testEvent", 
          testData: "testData"

        expect(events.list['testEvent']).toBeDefined()
        expect(events.list['testEvent']._lastArgs[0].testData).toBe("testData")


