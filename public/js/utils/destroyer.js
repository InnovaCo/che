(function() {

  define(["underscore"], function(_) {
    var destroyer;
    destroyer = function(object, is_deep) {
      return _.each(object, function(property, name) {
        if (object.hasOwnProperty(name)) {
          if (is_deep && _.isObject(property)) {
            _.delay(destroyer, property);
          }
          return delete object[name];
        }
      });
    };
    return destroyer;
  });

}).call(this);
