(function() {

  describe("Storage module", function() {
    return describe("Check interface", function() {
      var storage;
      storage = null;
      beforeEach(function() {
        storage = null;
        return require(["utils/storage"], function(storageModule) {
          return storage = storageModule;
        });
      });
      return it("should contain 'save', 'get', 'remove' and 'getKeys' functions", function() {
        waitsFor(function() {
          return storage !== null;
        });
        return runs(function() {
          expect(storage.save).toBeFunction();
          expect(storage.get).toBeFunction();
          expect(storage.remove).toBeFunction();
          return expect(storage.getKeys).toBeFunction();
        });
      });
    });
  });

}).call(this);
