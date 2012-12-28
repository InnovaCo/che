(function() {

  define([], function() {
    return {
      init: function(layout) {
        var className;
        className = this.element.className;
        return this.element.className = className + " " + this.name.replace("/", "-");
      }
    };
  });

}).call(this);
