(function() {

  define(['helpers/dom', 'lib/domReady'], function(dom, domReady) {
    var loadWidgetModule, preloader, searchForWidgets, widgetAttributName, widgetClassName;
    widgetClassName = 'widget';
    widgetAttributName = 'data-js-module';
    loadWidgetModule = function(domElement) {
      var widgetName;
      widgetName = domElement.getAttribute(widgetAttributName);
      if (!widgetName) {
        return false;
      }
      return require([widgetName], function(widget) {
        return widget.init(domElement);
      });
    };
    searchForWidgets = function() {
      var element, _i, _len, _ref, _results;
      _ref = dom.getElementByClass(widgetClassName);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        _results.push(preloader.loadWidgetModule(element));
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
