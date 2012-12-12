(function() {
  var localStorage, mockups;

  mockups = localStorage = {
    store: {},
    setItem: function(moduleName, key, value) {
      this.store["" + moduleName + "/" + key] = value;
      return true;
    },
    getItem: function(moduleName, key) {
      return this.store["" + moduleName + "/" + key];
    },
    removeItem: function(moduleName, key) {
      return this.store["" + moduleName + "/" + key] = null;
    },
    getKeys: function() {
      return this.store;
    }
  };

  describe("[Storage module]", function() {
    describe("Module interface", function() {
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
    return describe("Saving key/value", function() {
      var storage, _oldCookie, _oldLocalStorage, _oldSessionStorage;
      storage = null;
      _oldLocalStorage = null;
      _oldSessionStorage = null;
      _oldCookie = null;
      beforeEach(function() {
        storage = null;
        _oldLocalStorage = window.localStorage;
        _oldSessionStorage = window.sessionStorage;
        return require(["utils/storage"], function(storageModule) {
          return storage = storageModule;
        });
      });
      afterEach(function() {
        window.localStorage = _oldLocalStorage;
        return window.sessionStorage = _oldSessionStorage;
      });
      it("should save given key/value pair (both must be strings) with 'moduleName'-prefix to localStorage only (4-th parameter is false). If possible. ", function() {
        waitsFor(function() {
          return storage !== null;
        });
        return runs(function() {
          if (typeof window.localStorage === "undefined") {
            window.localStorage = mockups.localStorage;
          }
          storage.save("testModule", "testKey", "testValue");
          expect(window.localStorage.getItem("testModule/testKey")).toBe("testValue");
          return expect(window.sessionStorage.getItem("testModule/testKey")).toBe(null);
        });
      });
      it("should save given key/value pair (both must be strings) with 'moduleName'-prefix to sessionStorage only (4-th parameter is true). If possible.", function() {
        waitsFor(function() {
          return storage !== null;
        });
        return runs(function() {
          if (typeof window.localStorage === "undefined") {
            window.localStorage = mockups.localStorage;
          }
          if (typeof window.localStorage === "undefined") {
            window.localStorage = mockups.localStorage;
          }
          storage.save("testModule", "testKey", "testValue", true);
          expect(window.sessionStorage.getItem("testModule/testKey")).toBe("testValue");
          return expect(window.localStorage.getItem("testModule/testKey")).toBe(null);
        });
      });
      return it("should'nt save to anywahere given key/value pair with 'moduleName'-prefix if 'value' isn't string", function() {
        waitsFor(function() {
          return storage !== null;
        });
        return runs(function() {
          _oldLocalStorage = window.localStorage;
          if (typeof window.localStorage === "undefined") {
            window.localStorage = mockups.localStorage;
          }
          storage.save("testModule", "testKey", "testValue");
          expect(window.localStorage.getItem("testModule/testKey")).toBe("testValue");
          return window.localStorage = _oldLocalStorage;
        });
      });
    });
  });

}).call(this);
