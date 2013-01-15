(function() {

  define(['events', 'dom'], function(events, dom) {
    var HashHistory, originPushState, originReplaceState;
    if (window.history != null) {
      dom(window).on("popstate", function(e) {
        return events.trigger("history:popState", e);
      });
      originPushState = window.history.pushState;
      window.history.pushState = function() {
        originPushState.apply(window.history, arguments);
        return events.trigger("history:pushState", arguments);
      };
      originReplaceState = window.history.pushState;
      window.history.replaceState = function() {
        originReplaceState.apply(window.history, arguments);
        return events.trigger("history:replaceState", arguments);
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
