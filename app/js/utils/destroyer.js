(function() {

  define([], function() {
    return function(object) {
      return _.each(object, function(property, name) {
        if (object.hasOwnProperty(name)) {
          if (_.isObject(property)) {
            _.delay(destroyer, property);
          }
          return delete object[name];
        }
      });
    };
  });

}).call(this);
