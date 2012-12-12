describe "events module", ->
  describe "check interface", ->
    events = null

    beforeEach ->
      events = null
      @addMatchers ->
        toBeFunction: ->
          _.isFunction(@actual)

        toBeArray: ->
          _.isArray(@actual)
      require ["events"], (eventsModule) ->
        events = eventsModule
        events._data.previousArgs = {}
        events._data.handlers = {}

    it "should contain once, bind, unbind, trigger, pub, sub, unsub functions", ->
      waitsFor ->
        events isnt null
      runs ->
        expect(events.once).toBeFunction()
        expect(events.bind).toBeFunction()
        expect(events.unbind).toBeFunction()
        expect(events.trigger).toBeFunction()
        expect(events.pub).toBeFunction()
        expect(events.sub).toBeFunction()
        expect(events.unsub).toBeFunction()

  describe "binding handlers to events", ->
    events = null
    bindSpy = null
    onceSpy = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events._data.previousArgs = {}
        events._data.handlers = {}
        bindSpy = spyOn(events, "bind").andCallThrough()
        onceSpy = spyOn(events, "once").andCallThrough()

    it "should bind handler", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = ->
        events.bind "testEvent", handler, {}
        expect(handler.id).toBeDefined()
        expect(events._data.handlers["testEvent"]).toBeDefined()
        expect(events._data.handlers["testEvent"][handler.id].options).toBeDefined()
        expect(events._data.handlers["testEvent"][handler.id].id).toBe(handler.id)

    it "should unbind handler", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = ->
        events.bind "testEvent", handler, {}
        expect(events._data.handlers["testEvent"][handler.id].id).toBe(handler.id)
        events.unbind "testEvent", handler
        expect(events._data.handlers["testEvent"][handler.id]).not.toBeDefined()

    it "should call handler after binding (remember option is true)", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = jasmine.createSpy("handler")

        events.pub 'testEvent',
          testData: 'testData'

        events.bind "testEvent", handler, 
          isSync: true # to call handler syncronously, tests for isSync option are coming separately
          remember: true

        expect(handler).toHaveBeenCalled()

    it "shouldn't call handler after binding (remember option is false)", ->
      waitsFor ->
        events isnt null
      runs ->
        handler = jasmine.createSpy("handler")

        events.pub 'testEvent',
          testData: 'testData'

        events.bind "testEvent", handler, 
          isSync: true # to call handler syncronously, tests for isSync option are coming separately

        expect(handler).not.toHaveBeenCalled()

    it "should bind handler only once", ->
      waitsFor ->
        events isnt null
      runs ->
        handlerI = false
        handler = jasmine.createSpy("handler").andCallFake ->
          handlerIsCalled = true

        events.once 'testEvent', handler, 
          isSync: true # to call handler syncronously, tests for isSync option are coming separately

        expect(handler).not.toHaveBeenCalled()

        # calling event twice
        events.pub 'testEvent',
          testData: 'testData'

        expect(handler).toHaveBeenCalled()

        events.pub 'testEvent',
          testData: 'testData'

        expect(handler.calls.length).not.toBeGreaterThan(1)

  describe "calling handlers", ->
    events = null

    beforeEach ->
      events = null
      require ["events"], (eventsModule) ->
        events = eventsModule
        events._data.previousArgs = {}
        events._data.handlers = {}

    it "should call handler syncronously (isSync option is true)", ->
      waitsFor ->
        events isnt null
      runs ->
        syncHandler = jasmine.createSpy("syncHandler")

        events.bind "testEvent", syncHandler, 
          isSync: true

        events.pub 'testEvent',
          testData: 'testData'

        expect(syncHandler).toHaveBeenCalled()

    it "should call handler asyncronously (isSync option is false)", ->
      waitsFor ->
        events isnt null
      runs ->
        asyncHandler = jasmine.createSpy("asyncHandler")

        events.bind "testEvent", asyncHandler

        events.pub 'testEvent',
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
        events._data.previousArgs = {}
        events._data.handlers = {}

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
          events.bind "testEvent", handler, 
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
        expect(events._data.previousArgs["testEvent"]).not.toBeDefined()

        events.trigger "testEvent", 
          testData: "testData"

        expect(events._data.previousArgs["testEvent"]).toBeDefined()
        expect(events._data.previousArgs["testEvent"].testData).toBe("testData")