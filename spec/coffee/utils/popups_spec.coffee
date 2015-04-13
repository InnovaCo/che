# Story: Popup module

describe "[Popups module]", ->
  popups = null
  sections = null
  events = null
  beforeEach ->
    popups = null
    sections = null
    events = null
    require [
      "sections"
      "events"
      "utils/popups"
    ], (sectionsModule, eventsModule, popupsModule) ->
      sections = sectionsModule
      events = eventsModule
      popups = popupsModule
      popups.on()

    waitsFor ->
      popups isnt null

  afterEach ->
    popups.off()

  resetModules = () ->
    events.list = events.list
    sections._transitions.last = null
    sections._transitions.current = sections._transitions.create()

  ###### Narrative
  # *As* an any other module
  # *I want* to log my activity
  # *So that* I can use give API
  xdescribe "Module interface", ->
    beforeEach ->
      affix "div#one span.section"
      affix "div#two span.section"
      resetModules()

    reload_sections_with_popup =
      sections: "<section data-selector='#one' data-section-namespace='testNS'><span>hello</span></section>\
      <section data-selector='#two' data-section-namespace='popup'><div>popupContent</div></section>"

    it 'should have "on", "off", "getCurrentPopup", "isTurnedOn", "registerShowHideFunc", "unregisterShowHideFunc" methods', ->
      expect(popups.on).toBeFunction()
      expect(popups.off).toBeFunction()
      expect(popups.getCurrentPopup).toBeFunction()
      expect(popups.isTurnedOn).toBeFunction()
      expect(popups.registerShowHideFunc).toBeFunction()
      expect(popups.unregisterShowHideFunc).toBeFunction()

    it '.getCurrentPopup() must return current popup-section, if it is active"', ->
      sectionsReplaced = false
      popupInserted = false
      popupSection = {}

      events.bind "section-popup:inserted", (section) ->
        popupSection = section
        sectionsReplaced = true
        popupInserted = true


      transition = sections._transitions.create reload_sections_with_popup

      waitsFor ->
        popupInserted

      runs ->
        expect(popups.getCurrentPopup()).toBe popupSection
        expect($("#two div").text()).toBe "popupContent"

    it '.isTurnedOn() must return false after .off() called, and true after .on() called', ->
      popups.off()
      expect( popups.isTurnedOn() ).toBe off
      popups.on()
      expect( popups.isTurnedOn() ).toBe on


    it '.registerShowHideFunc() must register callbacks', ->
      customShowPopup = jasmine.createSpy "customShow"
      customHidePopup = jasmine.createSpy "customHide"
      popupInserted = false

      events.bind "section-popup:inserted", (section) ->
        popupInserted = true

      popups.registerShowHideFunc(customShowPopup, customHidePopup)
      transition = sections._transitions.create reload_sections_with_popup

      waitsFor ->
        popupInserted

      runs ->
        expect( customShowPopup ).toHaveBeenCalled()


    it '.unregisterShowHideFunc() must unregister callbacks', ->
      customShowPopup = jasmine.createSpy "customShow"
      customHidePopup = jasmine.createSpy "customHide"
      popupInserted = false

      events.bind "section-popup:inserted", (section) ->
        popupInserted = true

      popups.registerShowHideFunc(customShowPopup, customHidePopup)
      transition = sections._transitions.create reload_sections_with_popup

      waitsFor ->
        popupInserted

      runs ->
        expect( customShowPopup ).toHaveBeenCalled()

        resetModules()
        customShowPopup.reset()
        popupInserted = false

        popups.unregisterShowHideFunc()
        transition = sections._transitions.create reload_sections_with_popup

        waitsFor ->
          popupInserted

        runs ->
          expect( customShowPopup ).not.toHaveBeenCalled()




