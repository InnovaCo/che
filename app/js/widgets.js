(function() {

  define(["events", "dom", "utils/destroyer"], function(events, dom, destroyer) {
    var Widget, eventSplitter, widgets, widgetsInstances;
    widgetsInstances = {};
    eventSplitter = /^(\S+)\s*(.*)$/;
    ({
      bindWidgetDomEvents: function(eventsList, widget) {
        var elem;
        elem = dom(widget.element);
        return _.each(eventsList, function(eventDescr, handler) {
          var name, selector, splittedDescr;
          splittedDescr = eventDescr.split(eventSplitter);
          name = splittedDescr[1];
          selector = splittedDescr[2];
          handler = _.isString(handler) ? widget[handler] : handler;
          eventsList[eventDescr] = handler;
          return elem.on(name, selector, handler);
        });
      },
      unbindWidgetDomEvents: function(eventsData, widget) {
        return _.each(eventsData, function(eventDescr, handler) {
          var name, selector, splittedDescr;
          splittedDescr = eventDescr.split(eventSplitter);
          name = splittedDescr[1];
          selector = splittedDescr[2];
          return elem.off(name, selector, handler);
        });
      },
      bindWidgetModuleEvents: function(eventsList, widget) {
        return _.each(eventsList, function(handler, name) {
          handler = _.isString(handler) ? widget[handler] : handler;
          events.bind(name, handler, widget);
          return eventsList[name] = handler;
        });
      },
      unbindWidgetModuleEvents: function(eventsList) {
        return _.each(eventsList, function(handler, name) {
          return events.unbind(name, handler);
        });
      }
    });
    Widget = function(name, element, _widget) {
      var id;
      this.name = name;
      id = this.element.getAttribute("data-widget-" + this.name + "-id");
      if (id) {
        return widgetsInstances[id];
      }
      _.extend(this, _widget);
      this.id = _.uniqueId("widget_");
      this.element = element;
      this.init();
      this.isInitialized = true;
      this.element.getAttribute("data-widget-" + this.name + "-id", this.id);
      return widgetsInstances[this.id] = this;
    };
    Widget.prototype = {
      init: function() {
        if (this.isInitialized) {
          return this;
        }
        this.turnOn();
        return this;
      },
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
        unbindWidgetDomEvents(this.domEvents);
        unbindWidgetModuleEvents(this.moduleEvents);
        this._isOn = false;
        return this;
      },
      destroy: function() {
        var _base;
        this.turnOff();
        delete widgetsInstances[this.id];
        if (typeof (_base = this._widget).destroy === "function") {
          _base.destroy();
        }
        return destroyer(this);
      }
    };
    return widgets = {
      create: function(widgetData) {
        return require([widgetData.name], function(widget) {
          return new Widget(widgetData.name, widgetData.element, widget);
        });
      }
    };
  });

}).call(this);
