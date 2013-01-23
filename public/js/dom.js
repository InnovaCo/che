(function() {

  define(["utils/guid", "lib/domReady"], function(guid, domReady) {
    var bindEvent, callEventHandlers, checkIsElementMatchSelector, delegateEvent, domQuery, parseHtml, query, unbindEvent, undelegateEvent;
    checkIsElementMatchSelector = function(selectorOrNodeList, element, root) {
      var list, listElement, _i, _len;
      if (element === root || !element) {
        return false;
      }
      root = root || document;
      list = _.isString(selectorOrNodeList) ? domQuery(root).find(selectorOrNodeList).get() : selectorOrNodeList;
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        listElement = list[_i];
        if (listElement === element) {
          return true;
        }
      }
      return checkIsElementMatchSelector(list, element.parent, root);
    };
    callEventHandlers = function(handlers, eventObj, context) {
      var handler, result, _i, _len;
      for (_i = 0, _len = handlers.length; _i < _len; _i++) {
        handler = handlers[_i];
        result = handler.call(context, eventObj);
        if (result === false) {
          return false;
        }
      }
    };
    query = function(selector, root) {
      var result;
      if (window.jQuery) {
        query = function(selector, root) {
          return window.jQuery(root || document).find(selector).get();
        };
        return query.apply(this, arguments);
      }
      if (document.querySelectorAll != null) {
        if (_.isString(selector)) {
          root = !root || root.length === 0 ? document : root;
          if (!root.length) {
            root = [root];
          }
          result = [];
          _.each(root, function(root) {
            return result = result.concat(Array.prototype.slice.call(root.querySelectorAll(selector)));
          });
          return result;
        } else {
          return selector;
        }
      } else {
        return typeof console !== "undefined" && console !== null ? console.log("haven't tools for selecting node (module helpers/dom)") : void 0;
      }
    };
    unbindEvent = function(node, eventName, handler) {
      if (node.removeEventListener) {
        unbindEvent = function(node, eventName, handler) {
          return node.removeEventListener(eventName, handler, false);
        };
      } else if (node.detachEvent) {
        unbindEvent = function(node, eventName, handler) {
          return node.detachEvent("on" + eventName, handler);
        };
      } else {
        return typeof console !== "undefined" && console !== null ? console.log("cannot unbind event (module helpers/dom)") : void 0;
      }
      return unbindEvent.apply(this, arguments);
    };
    bindEvent = function(node, eventName, handler) {
      if (node.addEventListener) {
        bindEvent = function(node, eventName, handler) {
          return node.addEventListener(eventName, handler, false);
        };
      } else if (node.attachEvent) {
        bindEvent = function(node, eventName, handler) {
          return node.attachEvent("on" + eventName, handler);
        };
      } else {
        return typeof console !== "undefined" && console !== null ? console.log("cannot bind event (module helpers/dom)") : void 0;
      }
      return bindEvent.apply(this, arguments);
    };
    delegateEvent = function(node, selector, eventName, handler) {
      var delegateHandler;
      if (!node.domQueryDelegateHandler) {
        delegateHandler = function(e) {
          var eventObject, handlers, result, target;
          eventObject = e || window.event;
          target = eventObject.target || eventObject.srcElement;
          if (target.nodeType === 3) {
            target = target.parentNode;
          }
          if (node.domQueryHandlers[eventObject.type]) {
            handlers = node.domQueryHandlers[eventObject.type];
            result = true;
            _.each(handlers, function(handlers, selector) {
              if (checkIsElementMatchSelector(selector, target)) {
                return result = callEventHandlers(handlers, eventObject, target);
              }
            });
            return result;
          }
        };
        bindEvent(node, eventName, delegateHandler);
        node.domQueryDelegateHandler = delegateHandler;
      }
      handler.guid = handler.guid || guid();
      node.domQueryHandlers = node.domQueryHandlers || {};
      node.domQueryHandlers[eventName] = node.domQueryHandlers[eventName] || {};
      node.domQueryHandlers[eventName][selector] = node.domQueryHandlers[eventName][selector] || [];
      return node.domQueryHandlers[eventName][selector].push(handler);
    };
    undelegateEvent = function(node, selector, eventName, handler) {
      var handlers, index;
      if (!handler.guid) {
        return false;
      }
      if (!node.domQueryHandlers) {
        return false;
      }
      if (!node.domQueryHandlers[eventName]) {
        return false;
      }
      if (!node.domQueryHandlers[eventName][selector]) {
        return false;
      }
      handlers = node.domQueryHandlers[eventName][selector];
      index = null;
      _.find(handlers, function(delegateHandler, handlerIndex) {
        index = handlerIndex;
        return delegateHandler.guid === handler.guid;
      });
      if (index !== null) {
        handlers.splice(index, 1);
        return node.domQueryHandlers[eventName][selector] = handlers;
      }
    };
    parseHtml = function(plainHtml) {
      var div, node, _i, _len, _ref;
      div = document.createElement('DIV');
      div.innerHTML = plainHtml;
      _ref = div.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (node.nodeType === 3 && !/\S/.test(node.nodeValue)) {
          div.removeChild(node);
        }
      }
      return div.childNodes;
    };
    domQuery = function(selector) {
      var elements,
        _this = this;
      if (this instanceof domQuery) {
        if (selector instanceof domQuery) {
          return selector;
        }
        if (_.isString(selector)) {
          selector = selector.replace(/^\s+|\s+$/, "");
          if (selector.charAt(0) === "<" && selector.charAt(selector.length - 1) === ">" && selector.length >= 3) {
            elements = parseHtml(selector);
          } else {
            elements = query(selector);
          }
        } else {
          elements = selector || [document];
        }
        if (elements.length === void 0) {
          elements = [elements];
        }
        this.length = elements.length;
        this.selector = selector;
        return _.each(elements, function(element, index) {
          return _this[index] = element;
        });
      } else {
        return new domQuery(selector);
      }
    };
    domQuery.prototype = {
      on: function(selector, eventName, handler) {
        var args, binder;
        binder = arguments.length === 3 ? delegateEvent : bindEvent;
        args = Array.prototype.slice.call(arguments);
        _.each(this.get(), function(node, index) {
          return binder.apply(this, [node].concat(args));
        });
        return this;
      },
      off: function(selector, eventName, handler) {
        var args, unbinder;
        unbinder = arguments.length === 3 ? undelegateEvent : unbindEvent;
        args = Array.prototype.slice.call(arguments);
        _.each(this.get(), function(node, index) {
          return unbinder.apply(this, [node].concat(args));
        });
        return this;
      },
      find: function(selector) {
        return domQuery(query(selector, this.get()));
      },
      get: function(index) {
        if (index != null) {
          index = Math.max(0, Math.min(index, this.length - 1));
          return this[index];
        } else {
          return Array.prototype.slice.call(this);
        }
      },
      replaceWith: function(element) {
        return this[0] = this[0].parentNode.replaceChild(element[0] || element, this[0]);
      }
    };
    domQuery.load = function(name, req, onLoad, config) {
      domReady.load(name, req, function() {
        return onLoad(domQuery);
      }, config);
      return domQuery;
    };
    return domQuery;
  });

}).call(this);
