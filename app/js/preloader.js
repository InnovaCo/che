(function() {

  define(['lib/domReady', 'htmlParser'], function(domReady, htmlParser) {
    var loadWidgetModule, preloader, searchForWidgets;
    loadWidgetModule = function(widgetData) {
      return require([widgetData.name], function(widget) {
        return widget.init(widgetData.element);
      });
    };
    searchForWidgets = function() {
      var widgetData, _i, _len, _ref, _results;
      _ref = htmlParser(document);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        widgetData = _ref[_i];
        _results.push(preloader.loadWidgetModule(widgetData));
      }
      return _results;
    };
    preloader = {
      loadWidgetModule: loadWidgetModule,
      searchForWidgets: searchForWidgets
    };
    domReady(searchForWidgets);
    return preloader;
  });

}).call(this);
