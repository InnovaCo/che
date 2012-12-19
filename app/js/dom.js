(function() {

  define(["utils/guid"], function(guid) {
    var bindEvent, callEventHandlers, checkIsElementMatchSelector, delegateEvent, domQuery, query, unbindEvent, undelegateEvent;
    checkIsElementMatchSelector = function(selector, element) {
      var listOfElemevents;
      listOfElemevents = domQuery(selector).get();
      return _.find(listOfElemevents, function(elementFromlist) {
        return _.isEqual(elementFromlist, element);
      });
    };
    callEventHandlers = function(handlers, eventObj) {
      return _.each(handlers, function(handler) {
        return _.delay(handler, eventObj);
      });
    };
    query = function(selector, root) {
      if (document.querySelectorAll != null) {
        query = function(selector, root) {
          var result;
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
        };
      } else {
        query = function() {
          return typeof console !== "undefined" && console !== null ? console.log("haven't tools for selecting node (module helpers/dom)") : void 0;
        };
      }
      return query.apply(this, arguments);
    };
    unbindEvent = function() {};
    bindEvent = function(node, eventName, handler) {
      if (node.addEventListener) {
        bindEvent = function(node, eventName, handler) {
          return node.addEventListener(eventName, handler, false);
        };
        unbindEvent = function(node, eventName, handler) {
          return node.removeEventListener(eventName, handler, false);
        };
      } else if (node.attachEvent) {
        bindEvent = function(node, eventName, handler) {
          return node.attachEvent("on" + eventName, handler);
        };
        unbindEvent = function(node, eventName, handler) {
          return node.detachEvent(eventName, handler);
        };
      } else {
        bindEvent = function() {
          return typeof console !== "undefined" && console !== null ? console.log("cannot bind event (module helpers/dom)") : void 0;
        };
      }
      return bindEvent.apply(this, arguments);
    };
    delegateEvent = function(node, selector, eventName, handler) {
      var delegateHandler;
      if (!node.domQueryDelegateHandler) {
        delegateHandler = function(e) {
          var eventObject, handlers, target;
          eventObject = e || window.event;
          target = eventObject.target || eventObject.srcElement;
          if (target.nodeType === 3) {
            target = target.parentNode;
          }
          if (node.domQueryHandlers[eventObject.type]) {
            handlers = node.domQueryHandlers[eventObject.type];
            return _.each(handlers, function(handlers, selector) {
              if (checkIsElementMatchSelector(selector, target)) {
                return callEventHandlers(handlers, eventObject);
              }
            });
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
      if (index) {
        return node.domQueryHandlers[eventName][selector](handlers.splice(index, 1));
      }
    };
    domQuery = function(selector) {
      var elements, self;
      if (!domQuery.prototype._forget_jquery && window.jQuery) {
        domQuery = window.jQuery;
        return domQuery.apply(this, arguments);
      }
      if (this instanceof domQuery) {
        elements = query(selector || []);
        self = this;
        if (elements.length === void 0) {
          elements = [elements];
        }
        this.length = elements.length;
        return _.each(elements, function(element, index) {
          return self[index] = element;
        });
      } else {
        return new domQuery(selector);
      }
    };
    domQuery.prototype = {
      _forget_jquery: window.FORGET_JQUERY,
      on: function(selector, eventName, handler) {
        var args, binder;
        binder = arguments.length === 3 ? delegateEvent : bindEvent;
        args = Array.prototype.slice.call(arguments);
        return _.each(this.get(), function(node, index) {
          return binder.apply(this, [node].concat(args));
        });
      },
      off: function(selector, eventName, handler) {
        var args, unbinder;
        unbinder = arguments.length === 3 ? undelegateEvent : unbindEvent;
        args = Array.prototype.slice.call(arguments);
        return _.each(this.get(), function(node, index) {
          return unbinder.apply(this, [node].concat(args));
        });
      },
      find: function(selector) {
        if (!domQuery.prototype._forget_jquery && window.jQuery) {
          return window.jQuery(this.get()).find(selector);
        } else {
          return domQuery(query(selector, this.get()));
        }
      },
      get: function(index) {
        if (index != null) {
          index = Math.max(0, Math.min(index, this.length - 1));
          return this[index];
        } else {
          return Array.prototype.slice.call(this);
        }
      }
    };
    return domQuery;
  });

}).call(this);
