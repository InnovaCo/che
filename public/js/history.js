(function() {

  define(['events', 'dom'], function(events, dom) {
    var HashHistory, originOnpopstate, originPushState, originReplaceState;
    if (window.history != null) {
      originOnpopstate = window.onpopstate;
      window.onpopstate = function(popStateEvent) {
        if (originOnpopstate != null) {
          originOnpopstate.apply(window, arguments);
        }
        return events.trigger("history:popState", popStateEvent.state);
      };
      originPushState = window.history.pushState;
      window.history.pushState = function() {
        originPushState.apply(window.history, arguments);
        return events.trigger("history:pushState", Array.prototype.slice.call(arguments));
      };
      originReplaceState = window.history.pushState;
      window.history.replaceState = function() {
        originReplaceState.apply(window.history, arguments);
        return events.trigger("history:replaceState", Array.prototype.slice.call(Array, arguments));
      };
      return window.history;
    } else {
      return false;
    }
    HashHistory = function() {};
    return HashHistory.prototype = {
      length: 0,
      state: null,
      go: function(n) {},
      back: function() {},
      forward: function() {},
      pushState: function(data, title, url) {},
      replaceState: function(data, title, url) {}
    };
  });

}).call(this);
