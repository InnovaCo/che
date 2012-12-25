(function() {

  define(['htmlParser', 'widgets'], function(htmlParser, widgets) {
    var loadSections, loadWidgetModule, loader, searchForWidgets;
    loadWidgetModule = function(widgetData) {
      return widgets.create(widgetData.name, widgetData.element);
    };
    searchForWidgets = function(node) {
      var widgetData, _i, _len, _ref, _results;
      _ref = htmlParser(node || document);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        widgetData = _ref[_i];
        _results.push(loader.loadWidgetModule(widgetData));
      }
      return _results;
    };
    loadSections = function(sectionsData) {};
    return loader = {
      loadWidgetModule: loadWidgetModule,
      searchForWidgets: searchForWidgets,
      loadSections: loadSections
    };
  });

}).call(this);
