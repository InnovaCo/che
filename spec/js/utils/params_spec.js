(function() {

  describe("utils/params module", function() {
    var params;
    params = null;
    beforeEach(function() {
      require(["utils/params"], function(paramsModule) {
        return params = paramsModule;
      });
      return waitsFor(function() {
        return params != null;
      });
    });
    describe("encoding objects", function() {
      it("should encode object to params string", function() {
        var expectParams, testObject;
        testObject = {
          foo: "bar",
          fooBar: "foo bar",
          bar: {
            foo: "bar",
            zoo: {
              leo: "cat"
            }
          }
        };
        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat";
        return expect(params(testObject)).toBe(expectParams);
      });
      return it("should encode object to params string, invoke all functions inside it and place returned value", function() {
        var expectParams, testObject;
        testObject = {
          foo: function() {
            return "bar";
          },
          fooBar: "foo bar",
          bar: {
            foo: "bar",
            zoo: function() {
              return {
                leo: "cat"
              };
            }
          }
        };
        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat";
        return expect(params(testObject)).toBe(expectParams);
      });
    });
    return describe("work with another data", function() {
      it("should return same string if it received as parameter", function() {
        var expectParams;
        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat";
        return expect(params(expectParams)).toBe(expectParams);
      });
      return it("should invoke function if it was received as parameter", function() {
        var expectParams, testFunc;
        testFunc = function() {
          return {
            foo: function() {
              return "bar";
            },
            fooBar: "foo bar",
            bar: {
              foo: "bar",
              zoo: function() {
                return {
                  leo: "cat"
                };
              }
            }
          };
        };
        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat";
        return expect(params(testFunc)).toBe(expectParams);
      });
    });
  });

}).call(this);
