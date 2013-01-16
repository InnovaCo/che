(function() {

  define(['dom', 'config', 'events', "lib/domReady", "ajax"], function(dom, config, events, domReady, ajax) {
    var convertRequestData, loadSections, sectionsRequest;
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
    domReady(function() {
      dom('body').on("a[" + config.reloadSectionsDataAttributeName + "]", "click", function(e) {
        var data, url;
        data = this.getAttribute(config.reloadSectionsDataAttributeName);
        url = this.getAttribute('href');
        events.trigger("pageTransition:init", [url, convertRequestData(data)]);
        e.preventDefault();
        return false;
      });
      return events.bind("sectionsTransition:invoked, sectionsTransition:undone", function() {
        return events.trigger("pageTransition:stop");
      });
    });
    sectionsRequest = null;
    return loadSections = function(url, requestData) {
      if (sectionsRequest != null) {
        sectionsRequest.abort();
      }
      return sectionsRequest = ajax.get({
        url: url,
        data: requestData
      });
    };
  });

}).call(this);
