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
      }
    });
  });

}).call(this);
