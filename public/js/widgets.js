//@ sourceMappingURL=widgets.map
(function() {
  define(["events", "dom", "utils/destroyer", "config", "utils/guid", "underscore"], function(events, dom, destroyer, config, guid, _) {
    var Widget, bindWidgetDomEvents, bindWidgetModuleEvents, eventSplitter, unbindWidgetDomEvents, unbindWidgetModuleEvents, widgets, widgetsInstances, widgetsInterface;

    widgetsInstances = {};
    eventSplitter = /^(\S+)\s*(.*)$/;
    bindWidgetDomEvents = function(eventsList, widget) {
      var elem;

      elem = dom(widget.element);
      return _.each(eventsList, function(handler, eventDescr) {
        var name, selector, splittedDescr;

        splittedDescr = eventDescr.split(eventSplitter);
        name = splittedDescr[1];
        selector = splittedDescr[2];
        handler = _.isString(handler) ? widget[handler] : handler;
        eventsList[eventDescr] = handler;
        return elem.on(selector, name, handler);
      });
    };
    unbindWidgetDomEvents = function(eventsData, widget) {
      var elem;

      elem = dom(widget.element);
      return _.each(eventsData, function(handler, eventDescr) {
        var name, selector, splittedDescr;

        splittedDescr = eventDescr.split(eventSplitter);
        name = splittedDescr[1];
        selector = splittedDescr[2];
        return elem.off(selector, name, handler);
      });
    };
    bindWidgetModuleEvents = function(eventsList, widget) {
      return _.each(eventsList, function(handler, name) {
        handler = _.isString(handler) ? widget[handler] : handler;
        events.bind(name, handler, widget);
        return eventsList[name] = handler;
      });
    };
    unbindWidgetModuleEvents = function(eventsList) {
      return _.each(eventsList, function(handler, name) {
        return events.unbind(name, handler);
      });
    };
    widgets = {
      _instances: {},
      _id_attr: function(name) {
        return ("data-" + name + "-id").replace(/\//g, "-");
      },
      remove: function(widget) {
        widget.element.removeAttribute(this._id_attr(widget.name));
        delete this._instances[widget.id];
        return destroyer(widget);
      },
      get: function(name, element) {
        var id_attr;

        id_attr = this._id_attr(name);
        return this._instances[element.getAttribute(id_attr)];
      },
      add: function(name, element, _widget) {
        var instance, prevInstance;

        prevInstance = this.get(name, element);
        if (prevInstance != null) {
          return prevInstance;
        }
        instance = new Widget(name, element, _widget);
        instance.element.setAttribute(this._id_attr(name), instance.id);
        this._instances[instance.id] = instance;
        return instance;
      }
    };
    Widget = function(name, element, _widget) {
      this.name = name;
      this.element = element;
      _.extend(this, _widget);
      this.id = guid();
      if (typeof this.init === "function") {
        this.init(this.element);
      }
      this.turnOn();
      return this.isInitialized = true;
    };
    Widget.prototype = {
      turnOn: function() {
        if (this._isOn) {
          return;
        }
        bindWidgetDomEvents(this.domEvents, this);
        bindWidgetModuleEvents(this.moduleEvents, this);
        this._isOn = true;
        return this;
      },
      turnOff: function() {
        if (!this._isOn) {
          return;
        }
        unbindWidgetDomEvents(this.domEvents, this);
        unbindWidgetModuleEvents(this.moduleEvents, this);
        this._isOn = false;
        return this;
      },
      destroy: function() {
        this.turnOff();
        return widgets.remove(this);
      }
    };
    return widgetsInterface = {
      _manager: widgets,
      _constructor: Widget,
      get: function(name, element) {
        name = config.baseWidgetsPath + name;
        return widgets.get(name, element);
      },
      create: function(name, element, ready) {
        if (!/^http/.test(name)) {
          name = config.baseWidgetsPath + name;
        }
        return require([name], function(widget) {
          var instance;

          instance = widgets.add(name, element, widget);
          return typeof ready === "function" ? ready(instance) : void 0;
        });
      }
    };
  });

}).call(this);
