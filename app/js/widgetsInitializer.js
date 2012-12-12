(function() {

  define([], function() {
    var instances, loader, registerModuleInstance;
    instances = {};
    registerModuleInstance = function(name, instance) {
      instances[name] = instances[name] || {};
      return instances[name][instance.id] = instance;
    };
    loader = function(widgetName, domElement) {
      return require([widgetName], function(widget) {
        var instance;
        if (!domElement.getAttribute('data-widget-' + widgetName)) {
          instance = new widget.init(domElement);
          instance.id = instance.id || +(new Date);
          registerModuleInstance(widgetName, instance);
          return domElement.setAttribute('data-widget-' + widgetName, instance.id);
        }
      });
    };
    return loader;
  });

}).call(this);
