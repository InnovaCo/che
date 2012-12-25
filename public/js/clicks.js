(function() {

  define(['dom', 'config'], function(dom, config) {
    loadSections;
    return dom().on('a[#{config.reloadSectionsDataAttributeName}]', "click", function() {
      var data, element, reloadSectionsData;
      element = this;
      data = this.getAttribute(config.reloadSectionsDataAttributeName).split(/,\s*/);
      return reloadSectionsData = (new Fucntion("{" + data + "}")).call(this);
    });
  });

}).call(this);
