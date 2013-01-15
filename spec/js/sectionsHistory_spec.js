(function() {

  define('sectionsHistory module', function() {
    var history;
    history = null;
    beforeEach(function() {
      return require(['sectionsHistory'], function(historyModule) {
        return history = historyModule;
      });
    });
    describe('creating transitions', function() {
      it('should create transition and set firstTransition and currentTransition', function() {
        waitsFor(function() {
          return history != null;
        });
        return runs(function() {
          var transition;
          transition = new history._transition({}, null);
          expect(history._getFirstTransition()).toBe(transition);
          return expect(history._getCurrentTransition()).toBe(transition);
        });
      });
      it('should create transition and set previous created as .prev', function() {
        waitsFor(function() {
          return history != null;
        });
        return runs(function() {
          var nextTransition, transition;
          transition = new history._transition({}, null);
          nextTransition = transition.next({
            some: data
          });
          expect(transition).toBe(nextTransition.prev);
          return expect(transition.next).toBe(nextTransition);
        });
      });
      return it('should destroy first transition after 10 new created', function() {
        var firstTransition, i, transition, _i;
        firstTransition = new history._transition({}, null);
        transition = firstTransition;
        for (i = _i = 1; _i < 10; i = ++_i) {
          transition = transition.next({});
        }
        return expect(firstTransition).toBeEmpty();
      });
    });
    describe('invoking transitions', function() {
      it('should replace sections', function() {});
      return it('should replace sections and undo', function() {});
    });
    return describe('creating invoke objects', function() {});
  });

}).call(this);
