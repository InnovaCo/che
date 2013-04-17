describe "ajax module", ->
  ajax = null
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

    require ["ajax"], (ajaxModule) ->
      ajax = ajaxModule

    waitsFor ->
      ajax?


  afterEach ->
    window.XMLHttpRequest = realXMLHttpRequest

  describe "creating ajax object", ->
    it "should create ajax object, but witout sending AJAXrequest", ->
      instance = ajax()

      expect(instance.get).toBeFunction()
      expect(instance.complete).toBeFunction()
      expect(instance.start).toBeFunction()
      expect(instance.error).toBeFunction()
      expect(instance.success).toBeFunction()
      expect(instance.abort).toBeFunction()
      expect(instance._events).not.toBeDefined()
      expect(instance._request).not.toBeDefined()

    it "should create ajax object, and send request", ->
      start = jasmine.createSpy "start"
      instance = ajax
        url: "foo/bar",
        method: "POST",
        type: "json",
        data:
          foo: "bar",
          bar:
            zoo: "cat"
        start: start

      request = _.last XMLHttpRequestsList

      expect(request.open).toHaveBeenCalled()
      expect(request.open.mostRecentCall.args[0]).toBe("POST")
      expect(request.open.mostRecentCall.args[1]).toBe("foo/bar")
      expect(request.open.mostRecentCall.args[2]).toBe(true)

      expect(request.send).toHaveBeenCalled()
      expect(request.send.mostRecentCall.args[0]).toBe('foo=bar&bar%5Bzoo%5D=cat')
      expect(request.onreadystatechange).toBeFunction()
      expect(request.setRequestHeader).toHaveBeenCalled()

      waitsFor ->
        0 < start.calls.length
      runs ->
        expect(start).toHaveBeenCalled()

  describe 'changing ready state', ->
    it 'should do nothing, when state is 0, 1, 2, 3', ->
      error = jasmine.createSpy "error"
      success = jasmine.createSpy "success"
      complete = jasmine.createSpy "complete"

      instance = ajax.get
        url: "foo/bar",
        error: error,
        success: success,
        complete: complete

      request = instance._request

      request.readyState = 0
      request.onreadystatechange()
      request.readyState = 1
      request.onreadystatechange()
      request.readyState = 2
      request.onreadystatechange()
      request.readyState = 3
      request.onreadystatechange()

      expect(error).not.toHaveBeenCalled()
      expect(success).not.toHaveBeenCalled()
      expect(complete).not.toHaveBeenCalled()

    it 'should fire error and complete, when state is 4 and status not 200 or 304', ->
      error = jasmine.createSpy "error"
      success = jasmine.createSpy "success"
      complete = jasmine.createSpy "complete"

      instance = ajax.get
        url: "foo/bar",
        error: error,
        success: success,
        complete: complete

      request = instance._request

      request.readyState = 4
      request.status = 0
      request.onreadystatechange()

      waitsFor ->
        0 < error.calls.length and 0 < complete.calls.length
      runs ->
        expect(error).toHaveBeenCalled()
        expect(success).not.toHaveBeenCalled()
        expect(complete).toHaveBeenCalled()

    it 'should fire success and complete, when state is 4 and status is 200', ->
      error = jasmine.createSpy "error"
      success = jasmine.createSpy "success"
      complete = jasmine.createSpy "complete"

      instance = ajax.get
        url: "foo/bar"
        error: error
        success: success
        complete: complete

      request = instance._request

      request.readyState = 4
      request.status = 200
      request.onreadystatechange()

      waitsFor ->
        0 < success.calls.length and 0 < complete.calls.length
      runs ->
        expect(error).not.toHaveBeenCalled()
        expect(success).toHaveBeenCalled()
        expect(complete).toHaveBeenCalled()

  describe 'sending requests', ->
    it "should send get-request", ->
      instance = ajax.get
        url: "foo/bar"

      request = instance._request

      expect(request.open).toHaveBeenCalled()
      expect(request.open.mostRecentCall.args[0]).toBe("GET")
      expect(request.open.mostRecentCall.args[1]).toBe("foo/bar")
      expect(request.send).toHaveBeenCalled()

    it "should send request with x-che header", ->
      instance = ajax.get
        url: "foo/bar",
        data:
          foo: "bar",
          bar:
            zoo: "cat"

      request = instance._request
      expect(request.setRequestHeader).toHaveBeenCalled()
      expect(request.setRequestHeader.calls[1].args.join(',')).toBe "X-Che,true"

    it "should send get-request with params", ->
      instance = ajax.get
        url: "foo/bar",
        data:
          foo: "bar",
          bar:
            zoo: "cat"

      request = instance._request

      expect(request.open).toHaveBeenCalled()
      expect(request.open.mostRecentCall.args[0]).toBe("GET")
      expect(request.open.mostRecentCall.args[1]).toBe("foo/bar?foo=bar&bar%5Bzoo%5D=cat")
      expect(request.send).toHaveBeenCalled()


  describe 'recieving data', ->
    it "should parse json string", ->
      complete = jasmine.createSpy "complete"

      instance = ajax.get
        url: "foo/bar"
        type: "json"
        complete: complete

      request = instance._request

      request.readyState = 4
      request.status = 200
      request.responseText = '{"foo": "bar", "bar": {"zoo": "cat"}}'
      request.onreadystatechange()

      waitsFor ->
        0 < complete.calls.length and 0 < complete.calls.length
      runs ->
        expect(complete.mostRecentCall.args[1]).toBeEqual
          foo: "bar"
          bar:
            zoo: "cat"
