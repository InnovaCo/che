(function() {

  describe('htmlParser module', function() {
    describe('creating dom elements from plain html text', function() {});
    describe('creating array of pairs', function() {
      var parser;
      parser = null;
      beforeEach(function() {
        parser = null;
        return require(["htmlParser"], function(parserModule) {
          return parser = parserModule;
        });
      });
      it('should fill array with one pair', function() {
        waitsFor(function() {
          return parser !== null;
        });
        return runs(function() {
          var arrayOfPairs, domElement;
          arrayOfPairs = [];
          domElement = document.createElement("DIV");
          domElement.setAttribute('data-js-module', 'someModule');
          parser._save(arrayOfPairs, domElement);
          expect(arrayOfPairs.length).toBe(1);
          expect(arrayOfPairs[0].name).toBe('someModule');
          return expect(arrayOfPairs[0].element).toEqual(domElement);
        });
      });
      it('should fill array with two pairs, modules names in data-attribute are splitted by one comma', function() {
        waitsFor(function() {
          return parser !== null;
        });
        return runs(function() {
          var arrayOfPairs, domElement;
          arrayOfPairs = [];
          domElement = document.createElement("DIV");
          domElement.setAttribute('data-js-module', 'someModule,otherModule');
          parser._save(arrayOfPairs, domElement);
          expect(arrayOfPairs.length).toBe(2);
          expect(arrayOfPairs[0].name).toBe('someModule');
          expect(arrayOfPairs[1].name).toBe('otherModule');
          expect(arrayOfPairs[0].element).toEqual(domElement);
          return expect(arrayOfPairs[1].element).toEqual(domElement);
        });
      });
      it('should fill array with two pairs, modules names in data-attribute are splitted by one comma and space', function() {
        waitsFor(function() {
          return parser !== null;
        });
        return runs(function() {
          var arrayOfPairs, domElement;
          arrayOfPairs = [];
          domElement = document.createElement("DIV");
          domElement.setAttribute('data-js-module', 'someModule, otherModule');
          parser._save(arrayOfPairs, domElement);
          expect(arrayOfPairs.length).toBe(2);
          expect(arrayOfPairs[0].name).toBe('someModule');
          expect(arrayOfPairs[1].name).toBe('otherModule');
          expect(arrayOfPairs[0].element).toEqual(domElement);
          return expect(arrayOfPairs[1].element).toEqual(domElement);
        });
      });
      return it('should fill array with two pairs, in each pair module name should be the same', function() {
        waitsFor(function() {
          return parser !== null;
        });
        return runs(function() {
          var arrayOfPairs, domElement, domElement2;
          arrayOfPairs = [];
          domElement = document.createElement("DIV");
          domElement.setAttribute('data-js-module', 'someModule');
          domElement2 = document.createElement("DIV");
          domElement2.setAttribute('data-js-module', 'someModule');
          parser._save(arrayOfPairs, domElement);
          parser._save(arrayOfPairs, domElement2);
          expect(arrayOfPairs.length).toBe(2);
          expect(arrayOfPairs[0].name).toBe('someModule');
          expect(arrayOfPairs[1].name).toBe('someModule');
          expect(arrayOfPairs[0].element).toEqual(domElement);
          return expect(arrayOfPairs[1].element).toEqual(domElement2);
        });
      });
    });
    return describe('searching for modules', function() {
      var parser;
      parser = null;
      beforeEach(function() {
        var index, _i, _j, _k;
        parser = null;
        for (index = _i = 0; _i < 3; index = ++_i) {
          affix('div.widget[data-js-module="module_' + index + '"]');
        }
        for (index = _j = 0; _j < 3; index = ++_j) {
          affix('div.widget[data-js-module="module_fisrt_' + index + ',\
        module_second_' + index + '"]');
        }
        for (index = _k = 0; _k < 3; index = ++_k) {
          affix('div.widget[data-js-module="module_first_' + index + ',\
        module_second_' + index + ', module_thrird_' + index + ' "]');
        }
        return require(["htmlParser"], function(parserModule) {
          return parser = parserModule;
        });
      });
      it('should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in dom node', function() {
        waitsFor(function() {
          return parser !== null;
        });
        return runs(function() {
          var modulesNames, pairs;
          pairs = parser($('body')[0]);
          modulesNames = _.pluck(pairs, "name");
          console.log(modulesNames);
          expect(pairs.length).toBe(18);
          expect(modulesNames).toContain("module_0");
          expect(modulesNames).toContain("module_2");
          expect(modulesNames).toContain("module_first_0");
          expect(modulesNames).toContain('module_first_1');
          expect(modulesNames).toContain("module_second_0");
          expect(modulesNames).toContain("module_second_2");
          expect(modulesNames).toContain("module_thrird_0");
          return expect(modulesNames).toContain("module_thrird_2");
        });
      });
      return it('should return array of pairs: {name: moduleName, element: domElementRef}, for each found module name in plain HTML text', function() {
        waitsFor(function() {
          return parser !== null;
        });
        return runs(function() {
          var modulesNames, pairs;
          pairs = parser($('body').html());
          modulesNames = _.pluck(pairs, "name");
          expect(pairs.length).toBe(18);
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
  });

}).call(this);
