describe "widgets module", ->
  sampleWidget = null
  clickSpy = null
  sampleEventSpy = null
  anotherEventHandlerSpy = null

  beforeEach ->
    clickSpy = jasmine.createSpy 'clickSpy'
    mouseOverHandler = jasmine.createSpy 'mouseOverHandler'
    sampleEventSpy = jasmine.createSpy "sampleEventSpy"
    anotherEventHandlerSpy = jasmine.createSpy "anotherEventHandlerSpy"

    sampleWidget = 
      domEvents:
        "click a.action": clickSpy
        "mouseover div.mouser": "mouseOverHandler"
      mouseOverHandler: mouseOverHandlerSpy
      moduleEvents:
        "sampleEvent": sampleEventSpy
        "anotherEvent": "anotherEventHandler"
      anotherEventHandler: anotherEventHandlerSpy

      init: (element) ->
        dom(element).find("a").setAttribute('href', '')

    affix('div a.action').append('')

  describe "widget with events initialisation", ->

  describe 'turning widget off', ->

  describe 'turning widget on', ->

  describe 'destroy widget', ->
