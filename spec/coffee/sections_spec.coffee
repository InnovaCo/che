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
  Parser = null
  sectionsLoader = null
  cache = null
  require [
    'sections',
    'sections/asyncQueue',
    'sections/invoker',
    'sections/loader',
    'sections/parser',
    'events',
    'widgets',
    'utils/storage/storageFactory',
    'history',
    'ajax',
    'lib/async',
    'sections/cache'
    ], (sectionsModule, queueModule, invokerModule, loaderModule, parserModule, eventsModule, widgetsModule, storageFactory, browserHistoryModule, ajaxModule, asyncModule, cacheModule) ->
    sections = sectionsModule
    queue = queueModule
    Invoker = invokerModule
    sectionsLoader = loaderModule
    Parser = parserModule
    events = eventsModule
    bindedEvents = _.clone events.list
    widgets = widgetsModule
    storage = storageFactory.getStorage ['localStorage']
    browserHistory = browserHistoryModule
    ajax = ajaxModule
    async = asyncModule
    cache = cacheModule

  resetModules = () ->
    events.list = _.clone bindedEvents
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
      jasmine.Clock.useMock()
      transition = sections._transitions.create({index: 1})
      nextTransition = sections._transitions.create({sections: ""})

      jasmine.Clock.tick(1000)

      expect(sections._transitions.last).toBe(nextTransition)
      expect(sections._transitions.current).toBe(nextTransition)

    it 'should create transition and set previous created as .prev_transition', ->
      transition = sections._transitions.create({})
      nextTransition = sections._transitions.create({})

      expect(transition).toBe(nextTransition.prev_transition)
      expect(transition.next_transition).toBe(nextTransition)


  describe 'invoking transitions', ->
    reload_sections =
      sections: "<section data-selector='someName: #one'><span>hello</span></section>\
      <section data-selector='someName: #two'><span>world</span></section>"

    reload_sections_with_ns =
      sections: "<section data-selector='someName: #one'><span>hello</span></section>\
      <section data-selector='someName: #two'><span>world</span></section>"

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

    ###
    it 'should trigger event about each section with namespace due replacing sections', ->
      sectionsReplaced = false
      sectionWithNSInserted = false
      sectionWithSecondNSInserted = false

      events.bind "pageTransition:success", ->
        sectionsReplaced = true
      events.bind "section-testNS:inserted", ->
        sectionWithNSInserted = true
      events.bind "section-secondTestNS:inserted", ->
        sectionWithSecondNSInserted = true

      transition = sections._transitions.create reload_sections_with_ns

      waitsFor ->
        sectionsReplaced && sectionWithNSInserted && sectionWithSecondNSInserted

      runs ->
        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span.section").length).toBe 0
        expect($("#two span.section").length).toBe 0
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"

    it 'should replace sections and trigger events about section with namespace removed due undo', ->
      allDoneForward = no
      allDone = no
      sectionNSRemoved = no

      events.bind "pageTransition:success", (info) ->
        allDoneForward = info.transition.index is 1

      transition = sections._transitions.create reload_sections_with_ns

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

        events.bind "section-testNS:removed", (info) ->
          sectionNSRemoved = yes

        transition.prev()


        waitsFor ->
          allDone && sectionNSRemoved

        runs ->
          expect($("#one span.section").length).toBe 1
          expect($("#two span.section").length).toBe 1
    ###

  describe 'updating transitions', ->
    reload_sections =
      url: "test.com"
      sections: "<section data-selector='one: #one'><span>hello</span></section>\
      <section data-selector='two: #two'><span>world</span></section>"

    update_sections =
      url: "test.com"
      sections: "<section data-selector='one: #one'><span>Hello</span></section>\
      <section data-selector='two: #two'><span>Universe</span></section>"

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
      sections: "<title>megatitle!</title><section data-selector='one: #one'><span>hello</span></section>\
      <section data-selector='two: #two'><span>world</span></section>"
    parsedSections = null

    beforeEach ->

      parsedSections = Parser.parseSections reload_sections.sections

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
      invoker = new Invoker parsedSections.dom

      expect(invoker._back).toBe null
      expect(invoker._forward).toBe null
      expect(invoker._is_applied).toBe false
      expect(invoker._is_sections_updated).toBe false

    it "invoker should contain data for forward and backward transitions after it have ran", ->
      isInvoked = no


      invoker = new Invoker parsedSections
      invoker.run()

      queue.next ->
        isInvoked = yes

      waitsFor ->
        isInvoked

      runs ->
        expect(invoker._back).toBeDefined()
        expect(invoker._back["#one"]).toBeDefined()
        expect(invoker._back["#two"]).toBeDefined()
        expect(invoker._back["#one"].sectionHtml[0].outerHTML.toLowerCase()).toBe("<span class=\"section\"></span>")
        expect(invoker._back["#one"].sectionHtml[0].getAttribute("class")).toBe("section")
        # expect(invoker._back["#two"].widgetsInitData).toBeDefined()

        expect(invoker._forward).toBeDefined()
        expect(invoker._forward["#one"]).toBeDefined()
        expect(invoker._forward["#two"]).toBeDefined()
        expect(invoker._forward["#one"].sectionHtml[0].innerHTML.toLowerCase()).toBe("hello")
        expect(invoker._forward["#one"].sectionHtml[0].getAttribute("class")).toBe(null)

    it "invoker contain data for widgets turning off", ->
      invoker = new Invoker parsedSections
      invoker.run()

      # expect(invoker._back["#two"].widgetsInitData).toBeDefined()
      # expect(invoker._back["#two"].widgetsInitData[0].name).toBe('gradient')

    it "invoker should change sections", ->
      allDone = no
      events.bind "sections:inserted", ->
        allDone = yes

      invoker = new Invoker parsedSections
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
      sections: "<section data-selector='one: #one'><span class='widgets' data-js-widgets='widgets/rotation, widgets/gradient'>hello</span></section>\
      <section data-selector='two: #two'><span class='widgets' data-js-widgets='widgets/opacity'>world</span></section>"
    
    parsedSections = null

    beforeEach ->
      affix("div#one span.section.widgets").find('span').attr("data-js-widgets", "widgets/gradient")
      affix("div#two span.section.widgets").find('span').attr("data-js-widgets", "widgets/opacity")

      resetModules()

      spyOn(widgets, "create").andCallThrough()
      
      parsedSections = Parser.parseSections reload_sections.sections

    it "should init all widgets from new sections", ->
      allDone = no
      events.bind "sections:inserted", ->
        allDone = yes

      invoker = new Invoker parsedSections
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

        allDone = no
        events.bind "sections:inserted", ->
          allDone = yes

        invoker = new Invoker parsedSections
        invoker.run()

        waitsFor ->
          allDone is yes

        runs ->
          expect(gradient_widget._isOn).toBeFalsy()
          expect(opacity_widget._isOn).toBeFalsy()

  describe 'saving transition sections to localStorage', ->
    originalStorage = null
    
    reload_sections =
      url: window.location.origin
      title: "test Title"
      header: "header"
      sections: "<section data-selector='#one'><span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span></section>"

    beforeEach ->
      originalStorage = cache.getStorage()
      cache.setStorage(storage)
      storage.remove "sectionsHistory", window.location.origin
      affix "div#one span.section"

      resetModules()

    afterEach ->
      cache.setStorage(originalStorage)

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
        savedState = storage.get("sectionsHistory", window.location.origin + "|header:123")
        expect(savedState.sections).toBeDefined()
        expect(savedState.sections).toBe("<section data-selector='#one'><div></div></section>")

  describe 'loading transition sections', ->
    reload_sections = null
    beforeEach ->
      resetModules()
      reload_sections =
        url: window.location.origin
        sections: "<title>TITLE!</title>
          <section data-selector='one: #one'>sdkjhfksjd
          <span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span>
          </section>"
      affix "div#one span.section"
      spyOn(ajax, "get").andCallThrough()

    it "should load sections and correctly convert in to state object", ->
      loadedSections = "<title>TITLE!</title>
        <section data-selector='one: #one'>sdkjhfksjd
        <span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span>
        </section>"

      request =
        responseText: loadedSections
        getResponseHeader: (header) ->
          return "http://test.com/one/two" if header is "X-Che-Url"


      requestStub =
        abort: jasmine.createSpy("abort")
        success: (handler) ->
          handler request, loadedSections

      realAjaxDispatch = ajax.dispatch
      fakeAjaxDispatch = (params) ->
        return requestStub

      ajax.dispatch = fakeAjaxDispatch

      spyOn(events, "trigger").andCallThrough()

      sectionsLoader "http://test.com/one/two", "GET", "sections header", 1

      state = events.trigger.calls[0].args[1]
      
      expect(state.url).toBe("http://test.com/one/two")
      expect(state.sections).toBe("<title>TITLE!</title>
        <section data-selector='one: #one'>sdkjhfksjd
        <span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span>
        </section>")
      expect(state.method).toBe('GET')
      expect(state.sectionsHeader).toBe("sections header")
      expect(state.index).toBe(1)

      ajax.dispatch = realAjaxDispatch


    it "should update sections from server, when traversing sections", ->

      spyOn(ajax, "dispatch").andCallThrough()
      sections._transitions.last = null
      sections._transitions.current = sections._transitions.create()

      sections._transitions.create({index: 0, sections: "<div></div>"})

      events.trigger "history:popState",
        index: 0
        url: window.location.origin
        sections: "<section data-selector='one: #one'><div></div></section>"

      waitsFor ->
        0 < ajax.dispatch.calls.length

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
      origin = window.location.origin
      events.bind "transition:invoked", ->
        allDone = yes

      currentStorage = cache.getStorage()
      spyOn(currentStorage, "get").andCallThrough()
      currentStorage.save "sectionsHistory", origin + "|header:HEADER", reload_sections

      events.trigger "pageTransition:init", [origin, "HEADER", "GET", {}]

      waitsFor ->
        allDone is yes

      runs ->
        requestInfo = ajax.get.mostRecentCall.args[0]
        storageGetInfo = currentStorage.get.mostRecentCall.args

        expect(ajax.get).toHaveBeenCalled()
        expect(requestInfo.url).toBe origin
        expect(currentStorage.get).toHaveBeenCalled()
        expect(storageGetInfo[0]).toBe "sectionsHistory"
        expect(storageGetInfo[1]).toBe origin + "|header:HEADER"

  describe "traversing sections back", ->
    reloadSectionsArr = null
    originHistoryIndex = null
    beforeEach ->
      resetModules()
      affix "div.backHistory#one span.first"

      reloadSectionsArr = [
        index: 1
        url: "http://sections.com/one"
        sections: "<title>TITLE! number 1</title>
          <section data-selector='one: #one'>sdkjhfksjd
          <span class='widgets' data-js-modules='widgets/rotation, widgets/gradient'>hello</span>
          </section>"
      ,
        index: 2
        url: "http://sections.com/two"
        sections: "<title>TITLE! number 2</title>
          <section data-selector='one: #one'><span>Yo!</span>Man!
          </section>"
      ,
        index: 3
        url: "http://sections.com/three"
        sections: "<title>TITLE! number 3
          </title><section data-selector='one: #one'>Gangham<span class='yo'>style!</span>
          </section>"
      ,
        index: 4
        url: "http://sections.com/four"
        sections: "<title>TITLE! number 4</title>
          <section data-selector='one: #one'>Snop doggy<span class='yo'>dog!</span>
          </section>"
      ,
        index: 5
        url: "http://sections.com/five"
        sections: "<title>TITLE! number 5</title>
          <section data-selector='one: #one'><span class='end'>circus end!</span>
          </section>"
      ]

    afterEach ->
      # window.sections.go 1

    it "should change layout to previous state", ->
      allDone = no

      events.bind "pageTransition:success", (info) ->
        if info.transition.index is 5
          events.bind "pageTransition:success", (info) ->
            if info.transition.index is 1
              allDone = yes
          sections._transitions.go 1
      
      for state in reloadSectionsArr
        sections._transitions.create state

      waitsFor ->
        allDone
      runs ->
        expect($("title").text()).toBe "TITLE! number 1"
        expect($("div.backHistory#one span.widgets").text()).toBe "hello"

    it "should change url to previous state", ->
      #TODO: where is test?
      false
    it "should change layout to previous 3th state, when going to 3th prev state", ->
      #TODO: where is test?
      false
    it "should change url to previous 3th state, when going to 3th prev state", ->
      #TODO: where is test?
      false