describe "sections loader module", ->
  loader = errorHandler = events = null
  realXMLHttpRequest = null
  XMLHttpRequestsList = null
  beforeEach ->
    realXMLHttpRequest = window.XMLHttpRequest
    XMLHttpRequestsList = []
    window.XMLHttpRequest = ->
      request =
        send: jasmine.createSpy "send"
        onreadystatechange: null
        open: jasmine.createSpy "open"
        setRequestHeader: jasmine.createSpy "setRequestHeader"
        abort: jasmine.createSpy "abort"

      XMLHttpRequestsList.push request

      request

    require ["sections/loader", "utils/errorHandlers/errorHandler", "events"], (loaderModule, errorHandlerModule, eventsModule) ->
      loader = loaderModule
      errorHandler = errorHandlerModule
      events = eventsModule

    waitsFor ->
      loader?


  afterEach ->
    window.XMLHttpRequest = realXMLHttpRequest

  describe "creating correct ajax request", ->
    it "should send request with special x-che headers", ->
      loader '/test', 'GET', 'a:#b', 1, [], '{"c":true}'

      request = _.last XMLHttpRequestsList

      expect(request.open).toHaveBeenCalled()
      expect(request.open.mostRecentCall.args[0]).toBe("GET")
      expect(request.open.mostRecentCall.args[1]).toBe("/test")
      expect(request.open.mostRecentCall.args[2]).toBe(true)
      
      expect(request.setRequestHeader).toHaveBeenCalled()
      expect(request.setRequestHeader.calls[1].args.join(',')).toBe "X-Che,true"
      expect(request.setRequestHeader.calls[2].args.join(',')).toBe "X-Che-Sections,a:#b"
      expect(request.setRequestHeader.calls[3].args.join(',')).toBe "X-Che-Params,{\"c\":true}"

    it "should call error handler when request is fail", ->
      loader '/test', 'GET', 'a:#b', 1, [], '{"c":true}'

      processError = jasmine.createSpy "processError"

      handler =
        sectionLoadError: () -> processError(arguments)
      
      errorHandler.addErrorHandler handler

      request = _.last XMLHttpRequestsList

      request.readyState = 4
      request.status = 404
      request.onreadystatechange()

      waitsFor ->
        0 < processError.calls.length
      runs ->
        expect(processError).toHaveBeenCalled()
        expect(processError.mostRecentCall.args[0][0].errorCode).toBe(404)

  describe "processing dom selectors", ->
    it "should get sections from dom instead of server request", ->
      sectionsLoaded = null
      
      events.bind "sections:loaded", (sections) ->
        sectionsLoaded = sections

      affix 'div.test title'

      loader window.location.href, 'GET', '.test', 1, []

      request = _.last XMLHttpRequestsList

      waitsFor ->
        sectionsLoaded

      runs ->
        expect(request).toBe(undefined)
        expect(sectionsLoaded).toEqual(new window.history.CheState({
          url: window.location.href
          sectionsHeader : '.test'
          index : 1
          method : 'GET'
          sections : '<title></title>'
        }))

