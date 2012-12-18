(function() {

  define(['dom'], function(dom) {
    var createDomElement, getWidgetElements, parser, saveTo, widgetAttributName, widgetClassName;
    widgetClassName = 'widget';
    widgetAttributName = 'data-js-module';
    createDomElement = function(plainHtml) {
      var div;
      div = document.createElement('DIV');
      div.innerHTML = plainHtml;
      return div;
    };
    getWidgetElements = function(domElement) {
      return dom(domElement).find("." + widgetClassName).get();
    };
    saveTo = function(arrayOfPairs, element) {
      var moduleName, names, _i, _len;
      names = (element.getAttribute(widgetAttributName)).replace(/^\s|\s$/, '').split(/\s*,\s*/);
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        moduleName = names[_i];
        arrayOfPairs.push({
          name: moduleName,
          element: element
        });
      }
      return arrayOfPairs;
    };
    parser = function(html) {
      var arrayOfPairs, domElement, element, _i, _len, _ref;
      domElement = _.isString(html) ? createDomElement(html) : html;
      arrayOfPairs = [];
      _ref = getWidgetElements(domElement);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        saveTo(arrayOfPairs, element);
      }
      return arrayOfPairs;
    };
    parser._save = saveTo;
    return parser;
  });

}).call(this);
