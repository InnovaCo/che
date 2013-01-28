(function() {

  define(['widgets', 'config', 'utils/widgetsData', 'underscore', 'dom!'], function(widgets, config, widgetsData, _) {
    var loader;
    loader = {
      widgets: function(listWidgetsData, ready) {
        var data, list, widgetsCount, _i, _len, _results;
        widgetsCount = _.keys(listWidgetsData).length;
        list = [];
        if (widgetsCount === 0) {
          return typeof ready === "function" ? ready(list) : void 0;
        }
        _results = [];
        for (_i = 0, _len = listWidgetsData.length; _i < _len; _i++) {
          data = listWidgetsData[_i];
          _results.push(widgets.create(data.name, data.element, function(widget) {
            list.push(widget);
            widget.turnOn();
            widgetsCount -= 1;
            if (widgetsCount === 0) {
              return typeof ready === "function" ? ready(list, listWidgetsData) : void 0;
            }
          }));
        }
        return _results;
      },
      search: function(node, ready) {
        return loader.widgets(widgetsData(node), ready);
      }
    };
    loader.search();
    return loader;
  });

}).call(this);
