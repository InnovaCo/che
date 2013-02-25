describe 'sections module', ->
  sections = null
  events = null
  widgets = null
  storage = null
  browserHistory = null
  ajax = null
  async = null
  queue = null
  bindedEvents = null
  Invoker = null
  sectionsLoader = null
  require [
    'sections',
    'sections/asyncQueue', 
    'sections/invoker',
    'sections/loader',
    'events',
    'widgets',
    'utils/storage',
    'history',
    'ajax',
    'lib/async'
    ], (sectionsModule, queueModule, invokerModule, loaderModule, eventsModule, widgetsModule, storageModule, browserHistoryModule, ajaxModule, asyncModule) ->
    sections = sectionsModule
    queue = queueModule
    Invoker = invokerModule
    sectionsLoader = loaderModule
    events = eventsModule
    bindedEvents = events.list
    widgets = widgetsModule
    storage = storageModule
    browserHistory = browserHistoryModule
    ajax = ajaxModule
    async = asyncModule

  resetModules = () ->
    events.list = bindedEvents
    sections._transitions.last = null
    sections._transitions.current = sections._transitions.create()

    
  beforeEach ->
    spyOn(browserHistory, "pushState")
    
    waitsFor ->
      sections?

  afterEach ->
    allDone = false
    queue.stop()
    queue.next ->
      allDone = true
    waitsFor ->
      allDone

  describe 'creating transitions', ->
    beforeEach ->
      resetModules()

    it 'should create transition and set firstTransition and currentTransition', ->
      jasmine.Clock.useMock();
      transition = sections._transitions.create({index: 1})
      nextTransition = sections._transitions.create({sections: ""})

      jasmine.Clock.tick(1000);

      expect(sections._transitions.last).toBe(nextTransition)
      expect(sections._transitions.current).toBe(nextTransition)

    it 'should create transition and set previous created as .prev_transition', ->
      transition = sections._transitions.create({})
      nextTransition = sections._transitions.create({})

      expect(transition).toBe(nextTransition.prev_transition)
      expect(transition.next_transition).toBe(nextTransition)

    it 'should destroy first transition after 10 new created', ->
      firstTransition = sections._transitions.create {widgets: {}}

      transition = firstTransition
      for i in [1...10]
        transition = sections._transitions.create {index: i, widgets: {}}

      expect(firstTransition).toBeEmpty()



  describe 'invoking transitions', ->
    reload_sections = 
      sections: "<section data-selector='#one'><span>hello</span></section>\
      <section data-selector='#two'><span>world</span></section>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      resetModules()

    it 'should replace sections', ->
        sectionsReplaced = false

        events.bind "pageTransition:success", ->
          sectionsReplaced = true

        transition = sections._transitions.create reload_sections

        waitsFor ->
          sectionsReplaced

        runs ->
          expect($("#one").length).toBe 1
          expect($("#two").length).toBe 1
          expect($("#one span.section").length).toBe 0
          expect($("#two span.section").length).toBe 0
          expect($("#one span").text()).toBe "hello"
          expect($("#two span").text()).toBe "world"

    it 'should replace sections and undo', ->
      allDoneForward = no
      allDone = no
      events.bind "pageTransition:success", (info) ->
        allDoneForward = info.transition.index is 1

      transition = sections._transitions.create reload_sections

      waitsFor ->
        allDoneForward

      runs ->
        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"

        expect($("#one span.section").length).toBe 0
        expect($("#two span.section").length).toBe 0

        events.bind "pageTransition:success", (info) ->
          allDone = info.transition.index is 0

        transition.prev()


        waitsFor ->
          allDone

        runs ->
          expect($("#one span.section").length).toBe 1
          expect($("#two span.section").length).toBe 1


  describe 'updating transitions', ->
    reload_sections = 
      url: "test.com"
      sections: "<section data-selector='#one'><span>hello</span></section>\
      <section data-selector='#two'><span>world</span></section>"

    update_sections = 
      url: "test.com"
      sections: "<section data-selector='#one'><span>Hello</span></section>\
      <section data-selector='#two'><span>Universe</span></section>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      resetModules()


    it "should update sections", ->
        isCreated = no

        events.bind "pageTransition:success", ->
          isCreated = yes

        transition = sections._transitions.create reload_sections

        waitsFor ->
          isCreated

        runs ->

          expect($("#one").length).toBe 1
          expect($("#two").length).toBe 1
          expect($("#one span").text()).toBe "hello"
          expect($("#two span").text()).toBe "world"

          isUPdated = no

          events.bind "pageTransition:updated", ->
            isUPdated = yes

          transition.update _.extend({}, update_sections)

          waitsFor ->
            isUPdated

          runs ->
            expect($("#one").length).toBe 1
            expect($("#two").length).toBe 1
            expect($("#one span").text()).toBe "Hello"
            expect($("#two span").text()).toBe "Universe"

    it "shouldn't update sections", ->
        isCreated = no

        events.bind "pageTransition:success", ->
          isCreated = yes

        transition = sections._transitions.create reload_sections

        waitsFor ->
          isCreated

        runs ->

          expect($("#one").length).toBe 1
          expect($("#two").length).toBe 1
          expect($("#one span").text()).toBe "hello"
          expect($("#two span").text()).toBe "world"

          transition.update _.extend({}, reload_sections, {url: "url"})

          waits 500

          runs ->
            expect($("#one").length).toBe 1
            expect($("#two").length).toBe 1
            expect($("#one span").text()).toBe "hello"
            expect($("#two span").text()).toBe "world"


  describe 'creating invoke objects', ->
    reload_sections = 
      sections: "<title>megatitle!</title><section data-selector='#one'><span>hello</span></section>\
      <section data-selector='#two'><span>world</span></section>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two.widgets[data-js-modules=gradient] span.section"
      resetModules()

    it "should create invoke object if sections are specified", ->
      transition = sections._transitions.create reload_sections
      expect(transition._invoker).toBeDefined()

    it "shouldn't create invoke object 'cause sections arn't specified", ->
      transition = sections._transitions.create {}
      expect(transition._invoker).not.toBeDefined()

    it "invoker shouldn't contain data for forward and backward transitions right after initialization", ->
      invoker = new Invoker(reload_sections.sections)

      expect(invoker._back).toBe null
      expect(invoker._forward).toBe null
      expect(invoker._is_applied).toBe false
      expect(invoker._is_sections_updated).toBe false

    it "invoker should contain data for forward and backward transitions after it have ran", ->
      isInvoked = no
      invoker = new Invoker(reload_sections.sections)
      invoker.run()

      queue.next ->
        isInvoked = yes

      waitsFor ->
        isInvoked

      runs ->
        expect(invoker._back).toBeDefined()
        expect(invoker._back["#one"]).toBeDefined()
        expect(invoker._back["#two"]).toBeDefined()
        expect(invoker._back["#one"][0].outerHTML.toLowerCase()).toBe("<span class=\"section\"></span>")
        expect(invoker._back["#one"][0].getAttribute("class")).toBe("section")
        # expect(invoker._back["#two"].widgetsInitData).toBeDefined()

        expect(invoker._forward).toBeDefined()
        expect(invoker._forward["#one"]).toBeDefined()
        expect(invoker._forward["#two"]).toBeDefined()
        expect(invoker._forward["#one"][0].innerHTML.toLowerCase()).toBe("hello")
        expect(invoker._forward["#one"][0].getAttribute("class")).toBe(null)

    it "invoker contain data for widgets turning off", ->
      invoker = new Invoker(reload_sections.sections)
      invoker.run()

      # expect(invoker._back["#two"].widgetsInitData).toBeDefined()
      # expect(invoker._back["#two"].widgetsInitData[0].name).toBe('gradient')

    it "invoker should change sections", ->
      allDone = no;
      events.bind "sections:inserted", ->
        allDone = yes

      invoker = new Invoker(reload_sections.sections)
      invoker.run()

      waitsFor ->
        allDone is yes

      runs ->
        expect($('title').text()).toBe "megatitle!"
        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"


  describe 'initilize widgets', ->
    reload_sections = 
      sections: "<section data-selector='#one'><span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>\
      <section data-selector='#two'><span class='widgets' data-js-modules='widgets/opacity'>world</span></section>"

    beforeEach ->
      affix("div#one span.section.widgets").find('span').attr("data-js-modules", "widgets/gradient")
      affix("div#two span.section.widgets").find('span').attr("data-js-modules", "widgets/opacity")

      resetModules()

      spyOn(widgets, "create").andCallThrough()

    it "should init all widgets from new sections", ->
      allDone = no;
      events.bind "sections:inserted", ->
        allDone = yes

      invoker = new Invoker(reload_sections.sections)
      invoker.run()

      waitsFor ->
        allDone is yes

      runs ->
        expect(widgets.create.calls.length).toBe(3)

        expect(widgets.create.calls[0].args[0]).toBe("widgets/rotation")
        expect(widgets.create.calls[0].args[1]).toBeDomElement()
        expect(widgets.create.calls[0].args[2]).toBeFunction()

        expect(widgets.create.calls[1].args[0]).toBe("widgets/gradient")
        expect(widgets.create.calls[1].args[1]).toBeDomElement()
        expect(widgets.create.calls[1].args[2]).toBeFunction()

        expect(widgets.create.calls[2].args[0]).toBe("widgets/opacity")
        expect(widgets.create.calls[2].args[1]).toBeDomElement()
        expect(widgets.create.calls[2].args[2]).toBeFunction()

    it "should turn off all widgets from old sections", ->
      

      allwidgetsReady = no

      widgets.create "widgets/gradient", $("#one span")[0]
      widgets.create "widgets/opacity", $("#two span")[0]

      require ["widgets/gradient", "widgets/rotation", "widgets/opacity"], () ->
        allwidgetsReady = yes

      waitsFor ->
        allwidgetsReady is yes

      runs ->
        gradient_widget = widgets.get "widgets/gradient", $("#one span")[0]
        opacity_widget = widgets.get "widgets/opacity", $("#two span")[0]

        allDone = no;
        events.bind "sections:inserted", ->
          allDone = yes

        invoker = new Invoker reload_sections.sections 
        invoker.run()

        waitsFor ->
          allDone is yes

        runs ->
          expect(gradient_widget._isOn).toBeFalsy()
          expect(opacity_widget._isOn).toBeFalsy()

  describe 'saving transition sections to localStorage', ->
    reload_sections = 
      url: window.location.origin
      title: "test Title"
      header: "header"
      sections: "<section data-selector='#one'><span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>"

    beforeEach ->
      storage.remove "sectionsHistory", window.location.origin
      affix "div#one span.section"

      resetModules()
      


    it "should save sections data to localstorage", ->
      allDone = no
      events.bind "transition:invoked", ->
        allDone = yes

      events.trigger "sections:loaded", reload_sections

      waitsFor ->
        allDone is yes

      runs ->
        savedState = storage.get("sectionsHistory", window.location.origin + "|header:header")
        expect(savedState.sections).toBe(reload_sections.sections)
        expect(savedState.url).toBe(reload_sections.url)


    it "should update sections data in localstorage", ->
      allDone = no
      events.bind "transition:invoked", ->
        allDone = yes

      storage.save "sectionsHistory", reload_sections.url, reload_sections

      events.trigger "sections:loaded",
        url: window.location.origin
        title: "second test Title"
        header: "123"
        sections: "<section data-selector='#one'><div></div></section>"

      waitsFor ->
        allDone is yes

      runs ->
        savedState = storage.get("sectionsHistory", window.location.origin + "|header:123");
        expect(savedState.sections).toBeDefined()
        expect(savedState.sections).toBe("<section data-selector='#one'><div></div></section>")

  describe 'loading transition sections', ->
    reload_sections = null
    beforeEach ->
      resetModules()
      reload_sections = 
        url: window.location.origin
        sections: "<title>TITLE!</title><section data-selector='#one'>sdkjhfksjd<span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>"
      affix "div#one span.section"
      spyOn(ajax, "get").andCallThrough()

    it "should load sections and correctly convert in to state object", ->
      loadedSections = "<title>TITLE!</title><section data-selector='#one'>sdkjhfksjd<span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>"
      

      request = 
        responseText: loadedSections
        getResponseHeader: (header) ->
          return "http://test.com/one/two" if header is "X-Che-Url"


      requestStub = 
        abort: jasmine.createSpy("abort")
        success: (handler) ->
          handler request, loadedSections

      realAjaxGet = ajax.get
      fakeAjaxGet = (params) ->
        return requestStub

      ajax.get = fakeAjaxGet

      spyOn(events, "trigger").andCallThrough()

      sectionsLoader "http://test.com/one/two", "GET", "sections header", 1

      state = events.trigger.mostRecentCall.args[1]

      expect(state.url).toBe("http://test.com/one/two")
      expect(state.sections).toBe("<title>TITLE!</title><section data-selector='#one'>sdkjhfksjd<span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>")
      expect(state.method).toBe('GET')
      expect(state.header).toBe("sections header")
      expect(state.index).toBe(1)

      ajax.get = realAjaxGet


    it "should update sections from server, when traversing sections", ->
      
      allDone = no
      events.bind "transition:invoked", ->
        allDone = yes

      sections._transitions.last = null
      sections._transitions.current = sections._transitions.create()

      sections._transitions.create({index: 0, sections: "<div></div>"})

      events.trigger "history:popState",
        index: 0
        url: window.location.origin
        sections: "<section data-selector='#one'><div></div></section>"

      waitsFor ->
        allDone is yes

      runs ->
        requestInfo = ajax.get.mostRecentCall.args[0]
        expect(ajax.get).toHaveBeenCalled()
        expect(requestInfo.url).toBe(window.location.origin)


    it "should load sections from server, when going forward", ->
      
      allDone = no
      events.bind "transition:invoked", ->
        allDone = yes

      storage.save "sectionsHistory", reload_sections.url, reload_sections

      events.trigger "pageTransition:init", window.location.origin, {}

      waitsFor ->
        allDone is yes

      runs ->
        requestInfo = ajax.get.mostRecentCall.args[0]
        expect(ajax.get).toHaveBeenCalled()
        expect(requestInfo.url).toBe(window.location.origin)


    it "should load sections from localstorage, when going forward, and then update from server", ->
      
      allDone = no
      events.bind "transition:invoked", ->
        allDone = yes

      spyOn(storage, "get").andCallThrough()
      storage.save "sectionsHistory", window.location.origin + "|header:HEADER", reload_sections

      events.trigger "pageTransition:init", [window.location.origin, "HEADER", {}]

      waitsFor ->
        allDone is yes

      runs ->
        requestInfo = ajax.get.mostRecentCall.args[0]
        storageGetInfo = storage.get.mostRecentCall.args

        expect(ajax.get).toHaveBeenCalled()
        expect(requestInfo.url).toBe window.location.origin
        expect(storage.get).toHaveBeenCalled()
        expect(storageGetInfo[0]).toBe "sectionsHistory"
        expect(storageGetInfo[1]).toBe window.location.origin + "|header:HEADER"

  describe "traversing sections back", ->
    reloadSectionsArr = null
    originHistoryIndex = null
    beforeEach ->
      resetModules()
      affix "div.backHistory#one span.first"
      
      reloadSectionsArr = [
        index: 1
        url: "http://sections.com/one"
        sections: "<title>TITLE! number 1</title><section data-selector='#one'>sdkjhfksjd<span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>"
      , 
        index: 2
        url: "http://sections.com/two"
        sections: "<title>TITLE! number 2</title><section data-selector='#one'><span>Yo!</span>Man!</section>"
      ,
        index: 3
        url: "http://sections.com/three"
        sections: "<title>TITLE! number 3</title><section data-selector='#one'>Gangham<span class='yo'>style!</span></section>"
      ,
        index: 4
        url: "http://sections.com/four"
        sections: "<title>TITLE! number 4</title><section data-selector='#one'>Snop doggy<span class='yo'>dog!</span></section>"
      ,
        index: 5
        url: "http://sections.com/five"
        sections: "<title>TITLE! number 5</title><section data-selector='#one'><span class='end'>circus end!</span></section>"
      ]

    afterEach ->
      # window.sections.go 1

    it "should change layout to previous state", ->
      allDone = no

      for state in reloadSectionsArr
        sections._transitions.create state

      events.bind "pageTransition:success", (info) ->
        if info.transition.index is 5
          events.bind "pageTransition:success", (info) ->
            if info.transition.index is 1
              allDone = yes
          sections._transitions.go 1

      

      waitsFor ->
        allDone
      runs ->
        expect($("title").text()).toBe "TITLE! number 1"
        expect($("div.backHistory#one span.widgets").text()).toBe "hello"

    it "should change url to previous state", ->
    it "should change layout to previous 3th state, when going to 3th prev state", ->
    it "should change url to previous 3th state, when going to 3th prev state", ->