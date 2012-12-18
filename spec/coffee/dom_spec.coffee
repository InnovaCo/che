describe 'dom module', ->
  dom = null
  beforeEach ->
    require ['dom'], (domModule) ->
      dom = domModule

  describe 'binding events', ->
    beforeEach ->
      affix "div ul li a"

    it 'should bind event handler to element', ->
      waitsFor ->
        dom?
      runs ->
        bindSpy = jasmine.createSpy "bindSpy"
        dom("div ul li a").on 'click', bindSpy
        $("div ul li a").trigger('click')
        expect(bindSpy).toHaveBeenCalled()
        expect(bindSpy.guid).toBeDefined()
