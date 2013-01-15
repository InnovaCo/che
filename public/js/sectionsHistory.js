(function() {

  define(['events', 'widgets', 'dom', 'utils/destroyer', 'utils/widgetsData'], function(events, widgets, dom, destroyer, widgetsData) {
    /* 
    data:
      <selector>: <plainHTML>
    */

    var Invoker, Transition, depthTreshold;
    depthTreshold = 10;
    Transition = function(data, previousTransition) {
      var direction, _base;
      this.data = data;
      if (previousTransition != null) {
        this.prev = previousTransition;
        previousTransition.next = this;
      }
      if (this.data.index < Transition.last) {
        direction = "";
        if (Transition.current.index < this.data.index) {
          direction = "next";
        } else if (this.data.index < Transition.current.index) {
          direction = "prev";
        }
        Transition.current = (typeof (_base = Transition.current)[direction] === "function" ? _base[direction](this.data.index) : void 0) || Transition.current;
        return Transition.current;
      }
      this.depth = previousTransition ? previousTransition.depth + 1 : 0;
      this.index = this.data.index;
      Transition.last = this;
      Transition.current = this;
      if (this.data != null) {
        this._invoker = new Invoker(this.data.widgets);
        return this.invoke();
      }
    };
    Transition.first = null;
    Transition.last = null;
    Transition.current = null;
    Transition.prototype = {
      next: function(to_transition) {
        if (to_transition === this.index) {
          return this;
        }
        if (this.next != null) {
          this.next.invoke();
          Transition.current = this.next;
          if (to_transition != null) {
            return this.next.next(to_transition);
          }
        }
      },
      prev: function(to_transition) {
        if (to_transition === this.index) {
          return this;
        }
        if (this.prev != null) {
          this.undo();
          Transition.current = this.prev;
          if (to_transition != null) {
            return this.prev.prev(to_transition);
          }
        }
      },
      undo: function() {
        var _ref;
        return (_ref = this._invoker) != null ? _ref.undo() : void 0;
      },
      invoke: function() {
        var _ref;
        return (_ref = this._invoker) != null ? _ref.run() : void 0;
      }
    };
    Invoker = function(reloadSections) {
      this.reloadSections = reloadSections;
      this._back = null;
      return this._forward = null;
    };
    Invoker.prototype = {
      run: function() {
        var self;
        if (!this._forward && !this._back) {
          self = this;
          this._back = {};
          this._forward = {};
          _.each(this.reloadSections, function(html, selector) {
            return self._reloadSectionInit(selector, html);
          });
        }
        return this._insertSections(this._forward, this._back);
      },
      undo: function() {
        if (!this._forward && !this._back) {
          return false;
        }
        return this._insertSections(this._back, this._forward);
      },
      _reloadSectionInit: function(selector, html) {
        var nextElement, prevElement;
        prevElement = dom(selector);
        this._back[selector] = {
          widgets: [],
          element: prevElement,
          widgetsInitData: widgetsData(prevElement)
        };
        nextElement = dom(html);
        return this._forward[selector] = {
          widgets: [],
          element: nextElement,
          widgetsInitData: widgetsData(nextElement)
        };
      },
      _insertSections: function(forward, back) {
        var self;
        self = this;
        return _.each(forward, function(data, selector) {
          console.log(data.element[0]);
          return self._initWidgets(widgetsData(data.element), function(widgetsList) {
            var replaceableElement, widget, _i, _j, _len, _len1, _ref, _ref1, _ref2;
            forward[selector].widgets = widgetsList;
            replaceableElement = back[selector].element;
            if (back[selector].widgets) {
              _ref = back[selector].widgets;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                widget = _ref[_i];
                widget.turnOff();
              }
            } else if (back[selector].widgetsInitData) {
              _ref1 = back[selector].widgetsInitData;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                data = _ref1[_j];
                if ((_ref2 = widgets.get(data.name, data.element)) != null) {
                  _ref2.turnOff();
                }
              }
            }
            return replaceableElement.replaceWith(data.element);
          });
        });
      },
      _initWidgets: function(widgetsDataList, ready) {
        var data, list, widgetsCount, _i, _len, _results;
        console.log(widgetsDataList, "INIT");
        widgetsCount = _.keys(widgetsDataList).length;
        list = [];
        _results = [];
        for (_i = 0, _len = widgetsDataList.length; _i < _len; _i++) {
          data = widgetsDataList[_i];
          _results.push(widgets.create(data.name, data.element, function(widget) {
            list.push(widget);
            widget.turnOn();
            widgetsCount -= 1;
            if (widgetsCount === 0) {
              return ready(list);
            }
          }));
        }
        return _results;
      }
    };
    Transition.current = new Transition;
    events.bind("history:pushState", function(state) {
      console.log(state, "Loaded");
      return Transition(state);
    });
    events.bind("history:popState", function(state) {
      console.log(state, "Loaded");
      return Transition(state);
    });
    return {
      _getCurrentTransition: function() {
        return Transition.current;
      },
      _getFirstTransition: function() {
        return firstTransition;
      },
      _transition: Transition,
      _invoker: Invoker
    };
  });

}).call(this);
