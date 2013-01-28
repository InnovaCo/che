(function() {

  define(['events', 'utils/params', "utils/destroyer", "underscore"], function(events, params, destroyer, _) {
    var Ajax, XMLHttpFactories, ajax, createGETurl, createXMLHTTPObject, defaultOptions, eventName, parser, sendRequest, _i, _len, _ref;
    createGETurl = function(url, data) {
      var getParams, splittedUrl;
      splittedUrl = url.split("?");
      getParams = data != null ? "?" + (params(data)) : splittedUrl[1] ? "?" + splittedUrl[1] : "";
      return "" + splittedUrl[0] + getParams;
    };
    sendRequest = function(url, data, type, method, eventsSprout) {
      var request;
      request = createXMLHTTPObject();
      if (!request) {
        return false;
      }
      request.responseType = type;
      request.open(method, url, true);
      request.setRequestHeader('x-requested-with', 'xmlhttprequest');
      if (data != null) {
        data = params(data);
        request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
      }
      request.onreadystatechange = function() {
        if (request.readyState !== 4) {
          return;
        }
        data = request.responseText != null ? (parser[type] || parser.json)(request.responseText) : "";
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
          createXMLHTTPObject = function() {
            return xmlhttpConstructor();
          };
        } catch (e) {
          continue;
        }
        break;
      }
      return xmlhttp;
    };
    parser = {
      json: function(text) {
        console.log(text);
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
        this.get(options);
      }
      return this;
    };
    Ajax.prototype = {
      get: function(options) {
        var eventName, _i, _len, _ref;
        if (this._events) {
          destroyer(this._events);
        }
        if (options.url != null) {
          this._events = events.sprout();
          _ref = ["start", "success", "error", "complete"];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            eventName = _ref[_i];
            if (_.isFunction(options[eventName])) {
              this._events.bind(eventName, options[eventName], {
                recall: true
              });
            }
          }
          this._request = sendRequest(options.url, options.data || {}, options.type || "", options.method || defaultOptions.method, this._events);
        }
        return this;
      },
      abort: function() {
        this._request.abort();
        return this;
      }
    };
    _ref = ["start", "success", "error", "complete"];
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
    ajax.get = function(options) {
      options.method = "GET";
      options.url = createGETurl(options.url, options.data);
      return new Ajax(options);
    };
    return ajax;
  });

}).call(this);
