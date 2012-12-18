(function() {

  requirejs(['loader', 'lib/domReady'], function(loader, domReady) {
    return domReady(loader.searchForWidgets);
  });

}).call(this);
