# Story: Popup module

describe "[Popups module]", ->
  require ["sections","events", "utils/popup"], (sections, events, popup) ->

    beforeEach ->

    afterEach ->

    ###### Narrative
    # *As* an popup module
    # *I want* to know when the section with namespace "popup" is inserted into DOM
    # *So that* I can start animation for show this popup
    describe "At start of work", ->
      it "should create div with given selector for handling popups into it", ->
        
        # dom(config.popupContainerSelector)


    describe "Section with given namespace 'popup' is inserted, popup-module", ->
      reload_sections_with_popup =
        sections: "<section data-selector='#one' data-section-namespace='testNS'><span>hello</span></section>\
        <section data-selector='#two' data-section-namespace='popup'><div>popupContent</div></section>"

      it "should know about it", ->
        popupInserted = false
        sectionsReplaced = false

        events.bind "section-popup:inserted", ->
          popupInserted = true

        events.bind "pageTransition:success", ->
          sectionsReplaced = true

      transition = sections._transitions.create reload_sections_with_popup

      waitsFor ->
        sectionsReplaced && popupInserted

      runs ->
        expect($("#one").length).toBe 1
        expect($("#two").length).toBe 1
        expect($("#one span.section").length).toBe 0
        expect($("#two span.section").length).toBe 0
        expect($("#one span").text()).toBe "hello"
        expect($("#two span").text()).toBe "world"


