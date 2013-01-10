(function() {

  describe("ajax module", function() {
    var XMLHttpRequestsList, ajax, realXMLHttpRequest;
    ajax = null;
    realXMLHttpRequest = null;
    XMLHttpRequestsList = null;
    beforeEach(function() {
      realXMLHttpRequest = window.XMLHttpRequest;
      XMLHttpRequestsList = [];
      window.XMLHttpRequest = function() {
        var request;
        request = {
          send: jasmine.createSpy("send"),
          onreadystatechange: null,
          open: jasmine.createSpy("open"),
          setRequestHeader: jasmine.createSpy("setRequestHeader"),
          abort: jasmine.createSpy("abort")
        };
        XMLHttpRequestsList.push(request);
        return request;
      };
      return require(["ajax"], function(ajaxModule) {
        return ajax = ajaxModule;
      });
    });
    afterEach(function() {
      return window.XMLHttpRequest = realXMLHttpRequest;
    });
    describe("creating ajax object", function() {
      it("should create ajax object, but witout sending AJAXrequest", function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var instance;
          instance = ajax();
          expect(instance.get).toBeFunction();
          expect(instance.complete).toBeFunction();
          expect(instance.start).toBeFunction();
          expect(instance.error).toBeFunction();
          expect(instance.success).toBeFunction();
          expect(instance.abort).toBeFunction();
          expect(instance._events).not.toBeDefined();
          return expect(instance._request).not.toBeDefined();
        });
      });
      return it("should create ajax object, and send request", function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var instance, request, start;
          start = jasmine.createSpy("start");
          instance = ajax({
            url: "foo/bar",
            method: "POST",
            type: "json",
            data: {
              foo: "bar",
              bar: {
                zoo: "cat"
              }
            },
            start: start
          });
          request = _.last(XMLHttpRequestsList);
          expect(request.open).toHaveBeenCalled();
          expect(request.open.mostRecentCall.args[0]).toBe("POST");
          expect(request.open.mostRecentCall.args[1]).toBe("foo/bar");
          expect(request.open.mostRecentCall.args[2]).toBe(true);
          expect(request.send).toHaveBeenCalled();
          expect(request.send.mostRecentCall.args[0]).toBe('foo=bar&bar%5Bzoo%5D=cat');
          expect(request.onreadystatechange).toBeFunction();
          expect(request.setRequestHeader).toHaveBeenCalled();
          waitsFor(function() {
            return 0 < start.calls.length;
          });
          return runs(function() {
            return expect(start).toHaveBeenCalled();
          });
        });
      });
    });
    describe('changing ready state', function() {
      it('should do nothing, when state is 0, 1, 2, 3', function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var complete, error, instance, request, success;
          error = jasmine.createSpy("error");
          success = jasmine.createSpy("success");
          complete = jasmine.createSpy("complete");
          instance = ajax.get({
            url: "foo/bar",
            error: error,
            success: success,
            complete: complete
          });
          request = instance._request;
          request.readyState = 0;
          request.onreadystatechange();
          request.readyState = 1;
          request.onreadystatechange();
          request.readyState = 2;
          request.onreadystatechange();
          request.readyState = 3;
          request.onreadystatechange();
          expect(error).not.toHaveBeenCalled();
          expect(success).not.toHaveBeenCalled();
          return expect(complete).not.toHaveBeenCalled();
        });
      });
      it('should fire error and complete, when state is 4 and status not 200 or 304', function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var complete, error, instance, request, success;
          error = jasmine.createSpy("error");
          success = jasmine.createSpy("success");
          complete = jasmine.createSpy("complete");
          instance = ajax.get({
            url: "foo/bar",
            error: error,
            success: success,
            complete: complete
          });
          request = instance._request;
          request.readyState = 4;
          request.status = 0;
          request.onreadystatechange();
          waitsFor(function() {
            return 0 < error.calls.length && 0 < complete.calls.length;
          });
          return runs(function() {
            expect(error).toHaveBeenCalled();
            expect(success).not.toHaveBeenCalled();
            return expect(complete).toHaveBeenCalled();
          });
        });
      });
      return it('should fire success and complete, when state is 4 and status is 200', function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var complete, error, instance, request, success;
          error = jasmine.createSpy("error");
          success = jasmine.createSpy("success");
          complete = jasmine.createSpy("complete");
          instance = ajax.get({
            url: "foo/bar",
            error: error,
            success: success,
            complete: complete
          });
          request = instance._request;
          request.readyState = 4;
          request.status = 200;
          request.onreadystatechange();
          waitsFor(function() {
            return 0 < success.calls.length && 0 < complete.calls.length;
          });
          return runs(function() {
            expect(error).not.toHaveBeenCalled();
            expect(success).toHaveBeenCalled();
            return expect(complete).toHaveBeenCalled();
          });
        });
      });
    });
    describe('sending requests', function() {
      it("should send get-request", function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var instance, request;
          instance = ajax.get({
            url: "foo/bar"
          });
          request = instance._request;
          expect(request.open).toHaveBeenCalled();
          expect(request.open.mostRecentCall.args[0]).toBe("GET");
          expect(request.open.mostRecentCall.args[1]).toBe("foo/bar");
          return expect(request.send).toHaveBeenCalled();
        });
      });
      return it("should send get-request with params", function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var instance, request;
          instance = ajax.get({
            url: "foo/bar",
            data: {
              foo: "bar",
              bar: {
                zoo: "cat"
              }
            }
          });
          request = instance._request;
          expect(request.open).toHaveBeenCalled();
          expect(request.open.mostRecentCall.args[0]).toBe("GET");
          expect(request.open.mostRecentCall.args[1]).toBe("foo/bar?foo=bar&bar%5Bzoo%5D=cat");
          return expect(request.send).toHaveBeenCalled();
        });
      });
    });
    return describe('recieving data', function() {
      return it("should parse json string", function() {
        waitsFor(function() {
          return ajax != null;
        });
        return runs(function() {
          var complete, instance, request;
          complete = jasmine.createSpy("complete");
          instance = ajax.get({
            url: "foo/bar",
            type: "json",
            complete: complete
          });
          request = instance._request;
          request.readyState = 4;
          request.status = 200;
          request.responseText = '{"foo": "bar", "bar": {"zoo": "cat"}}';
          request.onreadystatechange();
          waitsFor(function() {
            return 0 < complete.calls.length && 0 < complete.calls.length;
          });
          return runs(function() {
            return expect(complete.mostRecentCall.args[1]).toBeEqual({
              foo: "bar",
              bar: {
                zoo: "cat"
              }
            });
          });
        });
      });
    });
  });

}).call(this);
