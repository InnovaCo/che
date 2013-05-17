describe 'sections/parser module', ->
  parser =
  require [
    'sections/parser'
    ], (parserModule) ->
    Parser = parserModule


  ## +Title: Defining selector type
  # In order to knowledge about next processing step
  # As a clever developer :)
  # I want to know what type of selector is in section
  #
  # +Scenario1: selector is string like any css-selector
  # Given logModule,
  # When requests the .empty()
  # Then log internal entries list should become empty
  #

  ###
  describe 'Parsing', ->
    sections = null
    beforeEach ->

      sections = "<title>title section</title>\
        <section data-selector='#one'><span class='widgets some_section' data-js-modules='testModule'>test</span>\
        </section>\
        <section data-selector='{"ns":["popup"]}'><span>some span</span></section>\
        <section data-selector='#two{otherNS}'><span>other span</span></section>"
      affix "#one div.some_another_section"

    describe "when given sections with css-selector", ->

      it 'should return object with "dom" field', ->
        resultObj = new Parser(sections)
        expect( resultObj ).toBeObject()
        expect( resultObj.dom ).toBeObject()

      it 'every field in this "dom"-object must be DOM-node', ->
        resultObj = new Parser(sections)
        expect( domField ).toBeDomElement() for key, domField of resultObj

    describe "when given sections with json-selector", ->

  ###
