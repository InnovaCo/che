(function() {

  define(["events", "dom", "utils/destroyer"], function(events, dom, destroyer) {
    var Widget, bindWidgetDomEvents, bindWidgetModuleEvents, eventSplitter, unbindWidgetDomEvents, unbindWidgetModuleEvents, widgets, widgetsInstances;
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
    Widget = function(name, element, _widget) {
      var id;
      this.name = name;
      this.element = element;
      id = this.element.getAttribute("data-widget-" + this.name + "-id");
      if (id && widgetsInstances[id]) {
        return widgetsInstances[id];
      }
      _.extend(this, _widget);
      this.id = _.uniqueId("widget_");
      if (typeof this.init === "function") {
        this.init(this.element);
      }
      this.turnOn();
      this.isInitialized = true;
      this.element.setAttribute("data-widget-" + this.name + "-id", this.id);
      return widgetsInstances[this.id] = this;
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
        this.element.removeAttribute("data-widget-" + this.name + "-id");
        delete widgetsInstances[this.id];
        return destroyer(this);
      }
    };
    return widgets = {
      _instances: widgetsInstances,
      _constructor: Widget,
      create: function(name, element, ready) {
        return require([name], function(widget) {
          return ready(new Widget(name, element, widget));
        });
      }
    };
  });

}).call(this);
