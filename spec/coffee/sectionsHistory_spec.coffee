describe 'sectionsHistory module', ->
  history = null
  events = null
  widgets = null
  storage = null
  browserHistory = null
  ajax = null
  require ['sectionsHistory', 'events', 'widgets', 'utils/storage', 'history', 'ajax'], (historyModule, eventsModule, widgetsModule, storageModule, browserHistoryModule, ajaxModule) ->
    history = historyModule
    events = eventsModule
    widgets = widgetsModule
    storage = storageModule
    browserHistory = browserHistoryModule
    ajax = ajaxModule

  history = null
  beforeEach ->
    history._transition.current = null
    waitsFor ->
      history?

  describe 'creating transitions', ->
    it 'should create transition and set firstTransition and currentTransition', ->
        transition = new history._transition({index: 1})
        nextTransition = new history._transition({widgets: {}})

        expect(history._transition.last).toBe(nextTransition)
        expect(history._transition.current).toBe(nextTransition)

    it 'should create transition and set previous created as .prev', ->
        transition = new history._transition({})
        nextTransition = new history._transition({})

        expect(transition).toBe(nextTransition.prev_transition)
        expect(transition.next_transition).toBe(nextTransition)

    it 'should destroy first transition after 10 new created', ->
      firstTransition = new history._transition {widgets: {}}

      transition = firstTransition
      for i in [1...10]
        transition = new history._transition {widgets: {}}

      expect(firstTransition).toBeEmpty()



  describe 'invoking transitions', ->
    reload_sections = 
      widgets:
        "#one": "<div id='three'><span>hello</span></div>"
        "#two": "<div id='four'><span>world</span></div>"

    update_sections = 
      widgets:
        "#three": "<div id='three'><span>Hello</span></div>"
        "#four": "<div id='four'><span>Universe</span></div>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      history._transition.last = null
      history._transition.current = null

    it 'should replace sections', ->
        transition = new history._transition reload_sections

        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "hello"
        expect($("#four span").text()).toBe "world"

    it 'should replace sections and undo', ->
        transition = new history._transition reload_sections

        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "hello"
        expect($("#four span").text()).toBe "world"

        transition.undo()

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#three").length).toBe 0
        expect($("#four").length).toBe 0

  describe 'updating transitions', ->
    reload_sections = 
      widgets:
        "#one": "<div id='three'><span>hello</span></div>"
        "#two": "<div id='four'><span>world</span></div>"

    update_sections = 
      widgets:
        "#one": "<div id='three'><span>Hello</span></div>"
        "#two": "<div id='four'><span>Universe</span></div>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      history._transition.last = null
      history._transition.current = null


    it "should update sections", ->
        transition = new history._transition reload_sections

        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "hello"
        expect($("#four span").text()).toBe "world"

        transition.update update_sections

        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "Hello"
        expect($("#four span").text()).toBe "Universe"

    it "shouldn't update sections", ->
        transition = new history._transition reload_sections

        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "hello"
        expect($("#four span").text()).toBe "world"

        transition.update _.extend({}, update_sections, {url: "url"})

        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "hello"
        expect($("#four span").text()).toBe "world"


  describe 'creating invoke objects', ->
    reload_sections = 
      widgets:
        "#one": "<div id='three'><span>hello</span></div>"
        "#two": "<div id='four' class='widgets' data-js-modules='gradient'><span>world</span></div>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two.widgets[data-js-modules=gradient] span.section"

      history._transition.last = null
      history._transition.current = null

    it "should create invoke object if sections are specified", ->
      transition = new history._transition reload_sections
      expect(transition._invoker).toBeDefined()

    it "shouldn't create invoke object 'cause sections arn't specified", ->
      transition = new history._transition {}
      expect(transition._invoker).not.toBeDefined()

    it "invoker shouldn't contain data for forward and backward transitions right after initialization", ->
      invoker = new history._invoker(reload_sections.widgets)

      expect(invoker._back).toBe null
      expect(invoker._forward).toBe null
      expect(invoker._is_applied).toBe false
      expect(invoker._is_sections_updated).toBe false

    it "invoker should contain data for forward and backward transitions after it have ran", ->
      invoker = new history._invoker(reload_sections.widgets)
      invoker.run()

      expect(invoker._back).toBeDefined()
      expect(invoker._back["#one"]).toBeDefined()
      expect(invoker._back["#two"]).toBeDefined()
      expect(invoker._back["#one"].element).toBeDefined()
      expect(invoker._back["#one"].element[0].innerHTML.toLowerCase()).toBe("<span class=\"section\"></span>")
      expect(invoker._back["#one"].element[0].getAttribute("id")).toBe("one")
      expect(invoker._back["#two"].widgetsInitData).toBeDefined()

      expect(invoker._forward).toBeDefined()
      expect(invoker._forward["#one"]).toBeDefined()
      expect(invoker._forward["#two"]).toBeDefined()
      expect(invoker._forward["#one"].element[0].innerHTML.toLowerCase()).toBe("<span>hello</span>")
      expect(invoker._forward["#one"].element[0].getAttribute("id")).toBe("three")
      expect(invoker._forward["#one"].element).toBeDefined()

    it "invoker contain data for widgets turning off", ->
      invoker = new history._invoker(reload_sections.widgets)
      invoker.run()

      expect(invoker._back["#two"].widgetsInitData).toBeDefined()
      expect(invoker._back["#two"].widgetsInitData[0].name).toBe('gradient')

    it "invoker should change sections", ->
      invoker = new history._invoker(reload_sections.widgets)
      invoker.run()

      waits(500)

      runs ->
        expect($("#one").length).toBe 0
        expect($("#two").length).toBe 0
        expect($("#three span").text()).toBe "hello"
        expect($("#four span").text()).toBe "world"


  describe 'initilize widgets', ->
    reload_sections = 
      widgets:
        "#one": "<div id='three' class='widgets' data-js-modules='rotation'><span>hello</span></div>"
        "#two": "<div id='four' class='widgets' data-js-modules='gradient, opacity'><span>world</span></div>"

    beforeEach ->
      affix "div#one.widgets[data-js-modules=gradient] span.section"
      affix "div#two.widgets[data-js-modules=opacity] span.section"

      history._transition.last = null
      history._transition.current = null

      spyOn(widgets, "create").andCallThrough()

    it "should init all widgets from new sections", ->
      allDone = no;
      events.bind "sections:inserted", ->
        allDone = yes

      invoker = new history._invoker(reload_sections.widgets)
      invoker.run()

      waitsFor ->
        allDone is yes

      runs ->
        expect(widgets.create.calls.length).toBe(3)

        expect(widgets.create.calls[0].args[0]).toBe("rotation")
        expect(widgets.create.calls[0].args[1]).toBeDomElement()
        expect(widgets.create.calls[0].args[2]).toBeFunction()

        expect(widgets.create.calls[1].args[0]).toBe("gradient")
        expect(widgets.create.calls[1].args[1]).toBeDomElement()
        expect(widgets.create.calls[1].args[2]).toBeFunction()

        expect(widgets.create.calls[2].args[0]).toBe("opacity")
        expect(widgets.create.calls[2].args[1]).toBeDomElement()
        expect(widgets.create.calls[2].args[2]).toBeFunction()

    it "should turn off all widgets from old sections", ->
      

      allwidgetsReady = no


      widgets.create "gradient", $("#one")[0]
      widgets.create "opacity", $("#two")[0]

      require ["widgets/gradient", "widgets/rotation", "widgets/opacity"], () ->
        allwidgetsReady = yes

      waitsFor ->
        allwidgetsReady is yes

      runs ->
        gradient_widget = widgets.get "gradient", $("#one")[0]
        opacity_widget = widgets.get "opacity", $("#two")[0]

        allDone = no;
        events.bind "sections:inserted", ->
          allDone = yes

        invoker = new history._invoker(reload_sections.widgets)
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
      widgets:
        "#one": "<div id='three' class='widgets' data-js-modules='rotation'><span>hello</span></div>"
        "#two": "<div id='four' class='widgets' data-js-modules='gradient, opacity'><span>world</span></div>"

    beforeEach ->
      storage.remove "sectionsHistory", window.location.origin
      affix "div#one span.section"

      spyOn(browserHistory, "pushState")

      history._transition.last = null
      history._transition.current = null
      


    it "should save sections data to localstorage", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
        allDone = yes

      events.trigger "sections:loaded", reload_sections

      waitsFor ->
        allDone is yes

      runs ->
        savedState = storage.get("sectionsHistory", window.location.origin)
        expect(savedState.widgets).toBeDefined()
        expect(savedState.title).toBe(reload_sections.title)
        expect(savedState.widgets["#one"]).toBe(reload_sections.widgets["#one"])
        expect(savedState.widgets["#two"]).toBe(reload_sections.widgets["#two"])


    it "should update sections data in localstorage", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
        allDone = yes

      storage.save "sectionsHistory", reload_sections.url, reload_sections

      events.trigger "sections:loaded",
        url: window.location.origin
        title: "second test Title"
        widgets:
          "#one": "<div></div>"

      waitsFor ->
        allDone is yes

      runs ->
        savedState = storage.get("sectionsHistory", window.location.origin);
        expect(savedState.widgets).toBeDefined()
        expect(savedState.title).toBe("second test Title")
        expect(savedState.widgets["#one"]).toBe("<div></div>")
        expect(savedState.widgets["#two"]).not.toBeDefined()

  describe 'loading transition sections', ->
    reload_sections = null
    beforeEach ->
      reload_sections = 
        url: window.location.origin
        title: "test Title"
        widgets:
          "#one": "<div id='three' class='widgets' data-js-modules='rotation'><span>hello</span></div>"

      affix "div#one span.section"
      spyOn ajax, "get"

    it "should update sections from server, when traversing history", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
        allDone = yes

      events.trigger "history:popState",
        url: window.location.origin
        title: "second test Title"
        widgets:
          "#one": "<div></div>"

      waitsFor ->
        allDone is yes

      runs ->
        requestInfo = ajax.get.mostRecentCall.args[0]
        expect(ajax.get).toHaveBeenCalled()
        expect(requestInfo.url).toBe(window.location.origin)


    it "should load sections from server, when going forward", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
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
        events.bind "sectionsTransition:invoked", ->
          allDone = yes

        spyOn(storage, "get").andCallThrough()
        storage.save "sectionsHistory", reload_sections.url, reload_sections

        events.trigger "pageTransition:init", window.location.origin, {}

        waitsFor ->
          allDone is yes

        runs ->
          requestInfo = ajax.get.mostRecentCall.args[0]
          storageGetInfo = storage.get.mostRecentCall.args

          expect(ajax.get).toHaveBeenCalled()
          expect(requestInfo.url).toBe window.location.origin
          expect(storage.get).toHaveBeenCalled()
          expect(storageGetInfo[0]).toBe "sectionsHistory"
          expect(storageGetInfo[1]).toBe window.location.origin

  describe 'getting state from history', ->