(function() {

  define(['dom', 'config', 'events', "lib/domReady", "utils/ajax"], function(dom, config, events, domReady, ajax) {
    var convertRequestData, loadSections, sectionsRequest;
    convertRequestData = function(paramsString) {
      var lisItem, list, reqestData, splittedData, _i, _len;
      list = paramsString.split(/,\s*/);
      reqestData = {};
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        lisItem = list[_i];
        splittedData = lisItem.split(/:\s*/);
        if (splittedData[0] !== "pageView") {
          reqestData.widgets = reqestData.widgets || {};
          reqestData.widgets[splittedData[0]] = splittedData[1];
        } else {
          reqestData[splittedData[0]] = splittedData[1];
        }
      }
      return reqestData;
    };
    domReady(function() {
      return dom('body').on("a[" + config.reloadSectionsDataAttributeName + "]", "click", function(e) {
        var data, url;
        data = this.getAttribute(config.reloadSectionsDataAttributeName);
        url = this.getAttribute('href');
        loadSections(url, convertRequestData(data));
        e.preventDefault();
        return false;
      });
    });
    sectionsRequest = null;
    return loadSections = function(url, reqestData) {
      console.log(url, reqestData);
      if (sectionsRequest != null) {
        sectionsRequest.abort();
      }
      return sectionsRequest = ajax({
        url: config.sectionsRequestUrl,
        data: reqestData
      });
    };
  });

}).call(this);
