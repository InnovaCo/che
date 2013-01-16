(function() {

  define(['dom', 'config'], function(dom, config) {
    var getWidgets, saveTo;
    saveTo = function(arrayOfPairs, element) {
      var moduleName, names, _i, _len, _ref;
      names = (_ref = element.getAttribute(config.widgetDataAttributeName)) != null ? _ref.replace(/^\s|\s$/, '').split(/\s*,\s*/) : void 0;
      if (!names) {
        return false;
      }
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        moduleName = names[_i];
        arrayOfPairs.push({
          name: moduleName,
          element: element
        });
      }
      return arrayOfPairs;
    };
    getWidgets = function(node) {
      var element, pairs, root, rootElement, widgetElements, _i, _j, _len, _len1;
      pairs = [];
      if (node && node !== document) {
        root = dom(node);
        for (_i = 0, _len = root.length; _i < _len; _i++) {
          rootElement = root[_i];
          saveTo(pairs, rootElement);
        }
      } else {
        root = dom(document);
      }
      widgetElements = root.find("." + config.widgetClassName).get();
      for (_j = 0, _len1 = widgetElements.length; _j < _len1; _j++) {
        element = widgetElements[_j];
        saveTo(pairs, element);
      }
      return pairs;
    };
    return getWidgets;
  });

}).call(this);
