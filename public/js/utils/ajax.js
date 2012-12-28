(function() {

  define(['events', 'utils/params', "utils/destroyer"], function(events, params, destroyer) {
    var Ajax, XMLHttpFactories, ajax, createXMLHTTPObject, defaultOptions, eventName, parser, sendRequest, _i, _len, _ref;
    sendRequest = function(url, data, type, eventsSprout) {
      var request;
      request = createXMLHTTPObject();
      if (!request) {
        return false;
      }
      request.responseType = type;
      request.open(method, url, true);
      request.setRequestHeader('User-Agent', 'XMLHTTP/1.0');
      if (data != null) {
        data = params(data);
        request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
      }
      request.onreadystatechange = function() {
        if (request.readyState !== 4) {
          return;
        }
        data = (parser[options.type] || parser["default"])(request.responseText);
        console.log(request);
        if (request.status !== 200 && request.status !== 304) {
          eventsSprout.trigger("error", [request, data]);
        } else {
          eventsSprout.trigger("success", [request, data]);
        }
        return eventsSprout.trigger("complete", [request, data]);
      };
      if (request.readyState === 4) {
        eventsSprout.trigger("complete", [request]);
        return request;
      }
      eventsSprout.trigger("start", [request]);
      request.send(data);
      return request;
    };
    XMLHttpFactories = [
      function() {
        return new XMLHttpRequest();
      }, function() {
        return new ActiveXObject("Msxml2.XMLHTTP");
      }, function() {
        return new ActiveXObject("Msxml3.XMLHTTP");
      }, function() {
        return new ActiveXObject("Microsoft.XMLHTTP");
      }
    ];
    createXMLHTTPObject = function() {
      var xmlhttp, xmlhttpConstructor, _i, _len;
      xmlhttp = false;
      for (_i = 0, _len = XMLHttpFactories.length; _i < _len; _i++) {
        xmlhttpConstructor = XMLHttpFactories[_i];
        try {
          xmlhttp = xmlhttpConstructor();
        } catch (e) {
          continue;
        }
        break;
      }
      return xmlhttp;
    };
    parser = {
      json: function(text) {
        return JSON.parse(text);
      },
      "default": function(text) {
        return text;
      }
    };
    defaultOptions = {
      type: 'json',
      method: "GET"
    };
    Ajax = function(options) {
      if (options != null) {
        return this.get(options);
      }
    };
    Ajax.prototype = {
      get: function(options) {
        var eventName, _i, _len, _ref, _ref1;
        if (this._events) {
          destroyer(this._events);
        }
        if (options.url != null) {
          this._events = events.sprout();
          _ref = ["start", "success", "error", "complete"];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            eventName = _ref[_i];
                        if ((_ref1 = options[eventName]) != null) {
              _ref1;

            } else {
              this._events.bind(eventName, options[eventName], {
                recall: true
              });
            };
          }
          this._request = sendRequest(options.url, options.data || {}, options.type || "", options.method || defaultOptions.method);
        }
        return this;
      },
      abort: function() {
        this._request.abort();
        return this;
      }
    };
    _ref = ["success", "error", "complete"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      eventName = _ref[_i];
      Ajax.prototype[eventName] = function(handler) {
        return this._events.bind(eventName, handler, {
          recall: true
        });
      };
    }
    ajax = function(options) {
      return new Ajax(options);
    };
    return ajax.get = function(options) {
      options.method = "GET";
      return new Ajax(options);
    };
  });

}).call(this);
