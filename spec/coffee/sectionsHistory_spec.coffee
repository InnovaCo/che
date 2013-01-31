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
    history._transitions.current = null
    spyOn(browserHistory, "pushState")
    waitsFor ->
      history?

  describe 'creating transitions', ->
    it 'should create transition and set firstTransition and currentTransition', ->
        transition = history._transitions.create({index: 1})
        nextTransition = history._transitions.create({sections: ""})

        expect(history._transitions.last).toBe(nextTransition)
        expect(history._transitions.current).toBe(nextTransition)

    it 'should create transition and set previous created as .prev_transition', ->
        transition = history._transitions.create({})
        nextTransition = history._transitions.create({})

        expect(transition).toBe(nextTransition.prev_transition)
        expect(transition.next_transition).toBe(nextTransition)

    it 'should destroy first transition after 10 new created', ->
      firstTransition = history._transitions.create {widgets: {}}

      transition = firstTransition
      for i in [1...10]
        transition = history._transitions.create {index: i, widgets: {}}

      expect(firstTransition).toBeEmpty()



  describe 'invoking transitions', ->
    reload_sections = 
      sections: "<section data-selector='#one'><span>hello</span></section>\
      <section data-selector='#two'><span>world</span></section>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      history._transitions.last = null
      history._transitions.current = null

    it 'should replace sections', ->
        transition = history._transitions.create reload_sections

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span.section").length).toBe 0
        expect($("#two span.section").length).toBe 0
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"

    it 'should replace sections and undo', ->
        transition = history._transitions.create reload_sections

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"

        expect($("#one span.section").length).toBe 0
        expect($("#two span.section").length).toBe 0

        transition.undo()

        expect($("#one span.section").length).toBe 1
        expect($("#two span.section").length).toBe 1


  describe 'updating transitions', ->
    reload_sections = 
      sections: "<section data-selector='#one'><span>hello</span></section>\
      <section data-selector='#two'><span>world</span></section>"

    update_sections = 
      sections: "<section data-selector='#one'><span>Hello</span></section>\
      <section data-selector='#two'><span>Universe</span></section>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      history._transitions.last = null
      history._transitions.current = null


    it "should update sections", ->
        transition = history._transitions.create reload_sections

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"

        transition.update update_sections

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "Hello"
        expect($("#two span").text()).toBe "Universe"

    it "shouldn't update sections", ->
        transition = history._transitions.create reload_sections

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"

        transition.update _.extend({}, update_sections, {url: "url"})

        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"


  describe 'creating invoke objects', ->
    reload_sections = 
      sections: "<section data-selector='#one'><span>hello</span></section>\
      <section data-selector='#two'><span>world</span></section>"

    beforeEach ->
      affix "div#one span.section"
      affix "div#two.widgets[data-js-modules=gradient] span.section"

      history._transitions.last = null
      history._transitions.current = null

    it "should create invoke object if sections are specified", ->
      transition = history._transitions.create reload_sections
      expect(transition._invoker).toBeDefined()

    it "shouldn't create invoke object 'cause sections arn't specified", ->
      transition = history._transitions.create {}
      expect(transition._invoker).not.toBeDefined()

    it "invoker shouldn't contain data for forward and backward transitions right after initialization", ->
      invoker = new history._invoker(reload_sections.sections)

      expect(invoker._back).toBe null
      expect(invoker._forward).toBe null
      expect(invoker._is_applied).toBe false
      expect(invoker._is_sections_updated).toBe false

    it "invoker should contain data for forward and backward transitions after it have ran", ->
      invoker = new history._invoker(reload_sections.sections)
      invoker.run()

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
      invoker = new history._invoker(reload_sections.sections)
      invoker.run()

      # expect(invoker._back["#two"].widgetsInitData).toBeDefined()
      # expect(invoker._back["#two"].widgetsInitData[0].name).toBe('gradient')

    it "invoker should change sections", ->
      invoker = new history._invoker(reload_sections.sections)
      invoker.run()

      waits(500)

      runs ->
        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"


  describe 'initilize widgets', ->
    reload_sections = 
      sections: "<section data-selector='#one'><span class='widgets' data-js-modules='rotation, gradient'>hello</span></section>\
      <section data-selector='#two'><span class='widgets' data-js-modules='opacity'>world</span></section>"

    beforeEach ->
      affix "div#one span.section.widgets[data-js-modules=gradient]"
      affix "div#two span.section.widgets[data-js-modules=opacity]"

      history._transitions.last = null
      history._transitions.current = null

      spyOn(widgets, "create").andCallThrough()

    it "should init all widgets from new sections", ->
      allDone = no;
      events.bind "sections:inserted", ->
        allDone = yes

      invoker = new history._invoker(reload_sections.sections)
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

      widgets.create "gradient", $("#one span")[0]
      widgets.create "opacity", $("#two span")[0]

      require ["widgets/gradient", "widgets/rotation", "widgets/opacity"], () ->
        allwidgetsReady = yes

      waitsFor ->
        allwidgetsReady is yes

      runs ->
        gradient_widget = widgets.get "gradient", $("#one span")[0]
        opacity_widget = widgets.get "opacity", $("#two span")[0]

        allDone = no;
        events.bind "sections:inserted", ->
          allDone = yes

        invoker = new history._invoker reload_sections.sections 
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
      sections: "<section data-selector='#one'><span class='widgets' data-js-modules='rotation, gradient'>hello</span></section>"

    beforeEach ->
      storage.remove "sectionsHistory", window.location.origin
      affix "div#one span.section"

      history._transitions.last = null
      history._transitions.current = null
      


    it "should save sections data to localstorage", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
        allDone = yes

      events.trigger "sections:loaded", reload_sections

      waitsFor ->
        allDone is yes

      runs ->
        savedState = storage.get("sectionsHistory", window.location.origin)
        expect(savedState.sections).toBe(reload_sections.sections)
        expect(savedState.url).toBe(reload_sections.url)


    it "should update sections data in localstorage", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
        allDone = yes

      storage.save "sectionsHistory", reload_sections.url, reload_sections

      events.trigger "sections:loaded",
        url: window.location.origin
        title: "second test Title"
        sections: "<section data-selector='#one'><div></div></section>"

      waitsFor ->
        allDone is yes

      runs ->
        savedState = storage.get("sectionsHistory", window.location.origin);
        expect(savedState.sections).toBeDefined()
        expect(savedState.sections).toBe("<section data-selector='#one'><div></div></section>")

  describe 'loading transition sections', ->
    reload_sections = null
    beforeEach ->
      reload_sections = 
        url: window.location.origin
        sections: "<title>TITLE!</title><section data-selector='#one'>sdkjhfksjd<span class='widgets' data-js-modules='rotation, gradient'>hello</span></section>"

      affix "div#one span.section"
      spyOn ajax, "get"

    it "should update sections from server, when traversing history", ->
      allDone = no
      events.bind "sectionsTransition:invoked", ->
        allDone = yes

      history._transitions.last = null
      history._transitions.current = null

      history._transitions.create({index: 0, sections: "<div></div>"})

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

  describe "traversing history back", ->
    it "should change layout to previous state", ->
    it "should change url to previous state", ->
    it "should change layout to previous 3th state, when going to 3th prev state", ->
    it "should change url to previous 3th state, when going to 3th prev state", ->