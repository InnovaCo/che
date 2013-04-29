describe "sections loader module", ->
  loader = null
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

    require ["sections/loader"], (loaderModule) ->
      loader = loaderModule

    waitsFor ->
      loader?


  afterEach ->
    window.XMLHttpRequest = realXMLHttpRequest

  describe "creating correct ajax rerquest", ->
    it "should send request with special x-che headers", ->
      loader '/test', 'GET', 'a:#b', 1, []

      request = _.last XMLHttpRequestsList

      expect(request.open).toHaveBeenCalled()
      expect(request.open.mostRecentCall.args[0]).toBe("GET")
      expect(request.open.mostRecentCall.args[1]).toBe("/test")
      expect(request.open.mostRecentCall.args[2]).toBe(true)
      
      expect(request.setRequestHeader).toHaveBeenCalled()
      expect(request.setRequestHeader.calls[1].args.join(',')).toBe "X-Che-Sections,a:#b"
      expect(request.setRequestHeader.calls[2].args.join(',')).toBe "X-Che,true"