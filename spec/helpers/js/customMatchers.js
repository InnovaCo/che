(function() {

  beforeEach(function() {
    return this.addMatchers({
      toBeFunction: function() {
        return _.isFunction(this.actual);
      },
      toBeArray: function() {
        return _.isArray(this.actual);
      }
    });
  });

}).call(this);
