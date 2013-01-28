(function() {

  describe("loader  module", function() {
    var loadSpy, loader, requireSpy;
    loader = null;
    loadSpy = null;
    requireSpy = null;
    beforeEach(function() {
      loader = null;
      require(["loader"], function(preloaderModule) {
        loader = preloaderModule;
        return loadSpy = spyOn(loader, "widgets").andCallThrough();
      });
      return waitsFor(function() {
        return loader !== null;
      });
    });
    describe("searching for widgets", function() {
      beforeEach(function() {
        var index, _i;
        for (index = _i = 0; _i <= 9; index = ++_i) {
          affix('div.widget[data-js-modules="module_' + index + '"]');
        }
        return requireSpy = spyOn(window, "require").andCallThrough();
      });
      it("should find all widgets on page", function() {
        loader.search();
        expect(loadSpy.calls.length).toEqual(1);
        return expect(loadSpy.mostRecentCall.args[0][9].name).toBe('module_9');
      });
      return it("should load all found widgets", function() {
        loader.search();
        expect(requireSpy.calls.length).toEqual(10);
        return expect(requireSpy.mostRecentCall.args[0][0]).toBe('widgets/module_9');
      });
    });
    return describe('searching for modules data', function() {
      beforeEach(function() {
        var index, parser, _i, _j, _k, _results;
        parser = null;
        for (index = _i = 0; _i < 3; index = ++_i) {
          affix('div.widget[data-js-modules="module_' + index + '"]');
        }
        for (index = _j = 0; _j < 3; index = ++_j) {
          affix('div.widget[data-js-modules="module_fisrt_' + index + ',\
        module_second_' + index + '"]');
        }
        _results = [];
        for (index = _k = 0; _k < 3; index = ++_k) {
          _results.push(affix('div.widget[data-js-modules="module_first_' + index + ',\
        module_second_' + index + ', module_thrird_' + index + ' "]'));
        }
        return _results;
      });
      it('should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in dom node', function() {
        var modulesNames;
        loader.search($('body')[0]);
        modulesNames = _.pluck(loadSpy.mostRecentCall.args[0], "name");
        expect(modulesNames.length).toBe(18);
        expect(modulesNames).toContain("module_0");
        expect(modulesNames).toContain("module_2");
        expect(modulesNames).toContain("module_first_0");
        expect(modulesNames).toContain('module_first_1');
        expect(modulesNames).toContain("module_second_0");
        expect(modulesNames).toContain("module_second_2");
        expect(modulesNames).toContain("module_thrird_0");
        return expect(modulesNames).toContain("module_thrird_2");
      });
      return it('should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in plain HTML text', function() {
        var modulesNames;
        loader.search($('body').html());
        modulesNames = _.pluck(loadSpy.mostRecentCall.args[0], "name");
        expect(modulesNames.length).toBe(18);
        expect(modulesNames).toContain("module_0");
        expect(modulesNames).toContain("module_2");
        expect(modulesNames).toContain("module_first_0");
        expect(modulesNames).toContain("module_first_1");
        expect(modulesNames).toContain("module_second_0");
        expect(modulesNames).toContain("module_second_2");
        expect(modulesNames).toContain("module_thrird_0");
        return expect(modulesNames).toContain("module_thrird_2");
      });
    });
  });

}).call(this);
