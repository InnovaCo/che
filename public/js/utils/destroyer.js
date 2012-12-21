(function() {

  define([], function() {
    var destroyer;
    destroyer = function(object) {
      return _.each(object, function(property, name) {
        if (object.hasOwnProperty(name)) {
          if (_.isObject(property)) {
            _.delay(destroyer, property);
          }
          return delete object[name];
        }
      });
    };
    return destroyer;
  });

}).call(this);
