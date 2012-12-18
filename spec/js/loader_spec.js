(function() {

  describe("loader  module", function() {
    return describe("searching for widgets", function() {
      var loadSpy, loader, requireSpy;
      loader = null;
      loadSpy = null;
      requireSpy = null;
      beforeEach(function() {
        var index, _i;
        loader = null;
        for (index = _i = 0; _i <= 9; index = ++_i) {
          affix('div.widget[data-js-module="module_' + index + '"]');
        }
        return require(["loader"], function(preloaderModule) {
          requireSpy = spyOn(window, "require").andCallThrough();
          loader = preloaderModule;
          return loadSpy = spyOn(loader, "loadWidgetModule").andCallThrough();
        });
      });
      it("should find all widgets on page", function() {
        waitsFor(function() {
          return loader !== null;
        });
        return runs(function() {
          loader.searchForWidgets();
          expect(loadSpy.calls.length).toEqual(10);
          return expect(loadSpy.mostRecentCall.args[0].name).toBe('module_9');
        });
      });
      return it("should load all found widgets", function() {
        waitsFor(function() {
          return loader !== null;
        });
        return runs(function() {
          loader.searchForWidgets();
          expect(requireSpy.calls.length).toEqual(10);
          return expect(requireSpy.mostRecentCall.args[0][0]).toBe('module_9');
        });
      });
    });
  });

}).call(this);
