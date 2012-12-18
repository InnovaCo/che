(function() {

  describe('guid module', function() {
    return describe('generating uniq id', function() {
      var guid;
      guid = null;
      beforeEach(function() {
        console.log('wait');
        guid = null;
        return require(['utils/guid'], function(guidModule) {
          console.log("guid", guidModule);
          return guid = guidModule;
        });
      });
      return it('should not generate two or more same ids', function() {
        waitsFor(function() {
          return guid !== null;
        });
        return runs(function() {
          var id, isFinished, isSame, iterator;
          id = guid;
          isSame = false;
          isFinished = false;
          iterator = function(iterationsCount) {
            isSame = id === guid() || isSame;
            if (0 < iterationsCount) {
              return _.delay(iterator, iterationsCount--);
            } else {
              return isFinished = true;
            }
          };
          iterator(1000);
          waitsFor(function() {
            return isFinished;
          });
          return runs(function() {
            return expect(isSame).toBe(false);
          });
        });
      });
    });
  });

}).call(this);
