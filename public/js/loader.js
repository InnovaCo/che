(function() {

  define(['widgets', 'config', 'utils/widgetsData', 'lib/domReady'], function(widgets, config, widgetsData, domReady) {
    var loadWidgetModule, loader, searchForWidgets;
    loadWidgetModule = function(widgetData) {
      return widgets.create(widgetData.name, widgetData.element);
    };
    searchForWidgets = function(node) {
      var widgetData, _i, _len, _ref, _results;
      _ref = widgetsData(node);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        widgetData = _ref[_i];
        _results.push(loader.loadWidgetModule(widgetData));
      }
      return _results;
    };
    loader = {
      loadWidgetModule: loadWidgetModule,
      searchForWidgets: searchForWidgets
    };
    domReady(searchForWidgets);
    return loader;
  });

}).call(this);
