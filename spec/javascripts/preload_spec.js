(function() {

  describe("preload  module", function() {
    describe("searching for widgets", function() {
      var preload;
      preload = null;
      beforeEach(function() {
        return preload = require("preload");
      });
      return it("should find all widgets on page", function() {
        var widgets;
        widgets = preload.test.findWidgets;
        return expect(widgets.toString()).toBe("");
      });
    });
    return describe("loading widgets to page", function() {
      var preload;
      preload = null;
      beforeEach(function() {
        return preload = require("preload");
      });
      return it("should load all the found widgets", function() {
        var is_all_loaded, widgets;
        widgets = preload.test.findWidgets;
        is_all_loaded = false;
        define([widgets], function() {
          return is_all_loaded = true;
        });
        waitsFor(function() {
          return is_all_loaded;
        });
        return runs(function() {});
      });
    });
  });

}).call(this);
