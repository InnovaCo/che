(function() {

  define(['dom', 'widgets', 'ajax', 'config', 'events'], function(dom, widgets, ajax, config, events) {
    var getWidgetElements, loadWidgetModule, loader, saveTo, searchForWidgets;
    getWidgetElements = function(domElement) {
      return dom(domElement).find("." + config.widgetClassName).get();
    };
    saveTo = function(arrayOfPairs, element) {
      var moduleName, names, _i, _len;
      names = (element.getAttribute(config.widgetDataAttributeName)).replace(/^\s|\s$/, '').split(/\s*,\s*/);
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        moduleName = names[_i];
        arrayOfPairs.push({
          name: moduleName,
          element: element
        });
      }
      return arrayOfPairs;
    };
    loadWidgetModule = function(widgetData) {
      return widgets.create(widgetData.name, widgetData.element);
    };
    searchForWidgets = function(node) {
      var element, pairs, widgetData, _i, _j, _len, _len1, _ref, _results;
      pairs = [];
      _ref = getWidgetElements(node || document);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        saveTo(pairs, element);
      }
      _results = [];
      for (_j = 0, _len1 = pairs.length; _j < _len1; _j++) {
        widgetData = pairs[_j];
        _results.push(loader.loadWidgetModule(widgetData));
      }
      return _results;
    };
    return loader = {
      loadWidgetModule: loadWidgetModule,
      searchForWidgets: searchForWidgets
    };
  });

}).call(this);
