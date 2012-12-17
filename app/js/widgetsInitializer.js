(function() {

  define(['widgets'], function(widgets) {
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
          instance = widgets.create(widget(domElement));
          instance.id = instance.id || +_.uniqueId;
          registerModuleInstance(widgetName, instance);
          return domElement.setAttribute('data-widget-' + widgetName, instance.id);
        }
      });
    };
    return loader;
  });

}).call(this);
