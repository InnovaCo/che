(function() {

  define([], function() {
    var bindHandlerToEvent, events, eventsData, handlerCall;
    eventsData = {
      handlers: {},
      previousArgs: {}
    };
    handlerCall = function(handler, eventName, args) {
      var eventData, handlerArgs;
      eventData = {
        name: eventName
      };
      handlerArgs = _.isArray(args) ? args : [args];
      handlerArgs.push(eventData);
      if (handler.options.isSync) {
        handler.apply(eventData, handlerArgs);
        return "sync";
      } else {
        _.delay(function() {
          return handler.apply(eventData, handlerArgs);
        });
        return "async";
      }
    };
    bindHandlerToEvent = function(eventName, handler, options) {
      handler.id = handler.id || _.uniqueId(eventName + "_handler_");
      handler.options = handler.options || options || {};
      eventsData.handlers[eventName] = eventsData.handlers[eventName] || {};
      eventsData.handlers[eventName][handler.id] = handler;
      if (eventsData.previousArgs[eventName] && options.remember) {
        return handlerCall(handler, eventName, eventsData.previousArgs[eventName]);
      }
    };
    events = {
      _data: eventsData,
      once: function(eventName, handler, options) {
        var onceHandler;
        onceHandler = function() {
          handler.apply(this, arguments);
          return events.unbind(eventName, onceHandler);
        };
        onceHandler.id = _.uniqueId(eventName + "_once_handler_");
        return events.bind(eventName, onceHandler, options);
      },
      bind: function(eventsNames, handler, options) {
        var compoundArguments, eventHandler, eventName, eventsList, _i, _len, _results;
        eventsList = _.compact(eventsNames.split(/\,+\s*|\s+/));
        if (/\,+/.test(eventsNames)) {
          compoundArguments = {};
          eventHandler = function() {
            var eventData;
            eventData = this;
            compoundArguments[eventData.name] = arguments;
            if (_.contains(eventsList, eventData.name)) {
              eventsList = _.without(eventsList, eventData.name);
            }
            if (eventsList.length === 0) {
              handler.call(this, compoundArguments);
            }
            return console.log(eventsList, eventsList.length);
          };
        } else {
          eventHandler = handler;
        }
        _results = [];
        for (_i = 0, _len = eventsList.length; _i < _len; _i++) {
          eventName = eventsList[_i];
          _results.push((function(eventName) {
            return bindHandlerToEvent(eventName, eventHandler, options);
          })(eventName));
        }
        return _results;
      },
      unbind: function(eventName, handler) {
        var id;
        id = handler.id;
        if (id && eventsData.handlers[eventName] && eventsData.handlers[eventName][id]) {
          return delete eventsData.handlers[eventName][id];
        }
      },
      trigger: function(eventName, args, options) {
        var caller, handlersList;
        handlersList = eventsData.handlers[eventName] || {};
        eventsData.previousArgs[eventName] = args;
        caller = function(handler) {
          return handlerCall(handler, eventName, args);
        };
        return _.each(handlersList, caller);
      }
    };
    events.pub = events.trigger;
    events.sub = events.bind;
    events.unsub = events.unbind;
    return events;
  });

}).call(this);
