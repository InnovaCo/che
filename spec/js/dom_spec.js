(function() {

  describe('dom module', function() {
    var dom;
    dom = null;
    beforeEach(function() {
      return require(['dom'], function(domModule) {
        return dom = domModule;
      });
    });
    return describe('binding events', function() {
      beforeEach(function() {
        return affix("div ul li a");
      });
      return it('should bind event handler to element', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var bindSpy;
          bindSpy = jasmine.createSpy("bindSpy");
          dom("div ul li a").on('click', bindSpy);
          $("div ul li a").trigger('click');
          expect(bindSpy).toHaveBeenCalled();
          return expect(bindSpy.guid).toBeDefined();
        });
      });
    });
  });

}).call(this);
