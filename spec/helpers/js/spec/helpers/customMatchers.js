(function() {

  beforeEach(function() {
    return this.addMatchers({
      toBeFunction: function() {
        return _.isFunction(this.actual);
      },
      toBeArray: function() {
        return _.isArray(this.actual);
      },
      toBeEmpty: function() {
        return _.isEmpty(this.actual);
      },
      toBeObject: function() {
        return _.isObject(this.actual);
      },
      toBeEqual: function(expecting) {
        return _.isEqual(this.actual, expecting);
      },
      toBeDomElement: function() {
        return this.actual.nodeType === 1 && (this.actual.nodeName != null) && (this.actual.nodeType != null);
      }
    });
  });

}).call(this);
