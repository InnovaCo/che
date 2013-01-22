(function() {

  define(['dom!', 'config', 'events', 'utils/params'], function(dom, config, events, params) {
    var convertRequestData;
    convertRequestData = function(paramsString) {
      var lisItem, list, requestData, splittedData, _i, _len;
      list = paramsString.split(/,\s*/);
      requestData = {};
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        lisItem = list[_i];
        splittedData = lisItem.split(/:\s*/);
        if (splittedData[0] !== "pageView") {
          requestData.widgets = requestData.widgets || {};
          requestData.widgets[splittedData[0]] = splittedData[1];
        } else {
          requestData[splittedData[0]] = splittedData[1];
        }
      }
      return requestData;
    };
    dom('body').on("a[" + config.reloadSectionsDataAttributeName + "]", "click", function(e) {
      var data, splitted_url, url;
      data = convertRequestData(this.getAttribute(config.reloadSectionsDataAttributeName));
      url = this.getAttribute('href');
      splitted_url = url.split("?");
      events.trigger("pageTransition:init", "" + splitted_url[0] + "?" + (splitted_url[1] || "") + "&" + (params(data)));
      e.preventDefault();
      return false;
    });
    return events.bind("sectionsTransition:invoked, sectionsTransition:undone", function() {
      return events.trigger("pageTransition:stop");
    });
  });

}).call(this);
