
# остальные тесты нужно постепенно перетащить из sections_spec.coffee, так как изначально invoker был внутри модуля sections

describe 'sections/invoker module', ->
  Invoker =
  queue = null
  require [
    'sections/invoker'
    'sections/asyncQueue'
    ], (invokerModule, queueModule) ->
    Invoker = invokerModule
    queue = queueModule

  # describe 'compress decompress testing', ->
  #   sections = null
  #   beforeEach ->

  #     define "testModule", ->
  #       init: (element) ->

  #     sections = "<title>title section</title><section data-selector='#one'><span class='widgets some_section' data-js-modules='testModule'>test</span></section>"
  #     affix "#one div.some_another_section"

  #   it 'should compress back and forward sections', ->
  #     invoker = new Invoker sections
  #     invoker.initializeSections()
  #     allDone = no
  #     queue.next ->
  #       invoker.compress()
  #       allDone = yes

  #     waitsFor ->
  #       allDone
  #     runs ->
  #       expect(invoker._back["#one"][0]).toBeString()
  #       expect(invoker._forward["#one"][0]).toBeString()
  #       expect(invoker._forward["title"][0]).toBeString()

  #       expect(invoker._back["#one"][0].toLowerCase()).toBe '<div class="some_another_section"></div>'
  #       expect(invoker._forward["#one"][0].toLowerCase()).toBe '<span class="widgets some_section" data-js-modules="testmodule">test</span>'
  #       expect(invoker._forward["title"][0]).toBe "title section"

  #   it 'should decompress back and forward sections', ->
  #     invoker = new Invoker sections
  #     invoker.initializeSections()
  #     allDone = no
  #     queue.next ->
  #       invoker.compress()
  #       invoker.decompress()
  #       allDone = yes

  #     waitsFor ->
  #       allDone
  #     runs ->
  #       expect(invoker._back["#one"][0][0]).toBeDomElement()
  #       expect(invoker._back["#one"][0][0].getAttribute("class")).toBe("some_another_section")
  #       expect(invoker._forward["#one"][0][0]).toBeDomElement()
  #       expect(invoker._forward["#one"][0][0].getAttribute("class")).toBe("widgets some_section")
  #       expect(invoker._forward["#one"][0][0].getAttribute("data-js-modules")).toBe("testModule")

  #   it 'should decompress and run back and forward sections', ->
  #     invoker = new Invoker sections
  #     invoker.initializeSections()
  #     allDone = no
  #     queue.next ->
  #       invoker.compress()
  #       invoker.decompress()
  #       invoker.run()
  #       allDone = yes

  #     waitsFor ->
  #       allDone
  #     runs ->
  #       expect($("#one").text()).toBe "test"

