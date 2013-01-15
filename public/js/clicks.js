(function() {

  define(['dom', 'config', 'history', "lib/domReady", "ajax"], function(dom, config, history, domReady, ajax) {
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
      var historyIndex;
      console.log(history);
      if (!history) {
        return false;
      }
      historyIndex = 0;
      return dom('body').on("a[" + config.reloadSectionsDataAttributeName + "]", "click", function(e) {
        var data, url;
        data = this.getAttribute(config.reloadSectionsDataAttributeName);
        url = this.getAttribute('href');
        loadSections(url, convertRequestData(data)).success(function(request, data) {
          return history.pushState({
            index: historyIndex++,
            widgets: data.widgets
          }, data.title, data.url);
        });
        e.preventDefault();
        return false;
      });
    });
    sectionsRequest = null;
    return loadSections = function(url, requestData) {
      console.log(url, requestData);
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
