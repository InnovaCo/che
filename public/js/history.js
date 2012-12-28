(function() {

  define(['events', 'widgets', 'dom', 'destroyer'], function(events, widgets, dom, destroyer) {
    /* 
    data:
      <selector>: <plainHTML>
    */

    var Invoker, Transition, currentTransition, depthTreshold, firstTransition, lastTransition;
    depthTreshold = 10;
    firstTransition = null;
    lastTransition = null;
    Transition = function(data, previousTransition) {
      var currentTransition, next;
      this.data = data;
      this.prev = previousTransition || null;
      this.depth = previousTransition ? previousTransition.depth + 1 : 0;
      if (firstTransition === null) {
        firstTransition = this;
      } else if (depthTreshold < this.depth - (firstTransition.depth != null)) {
        next = firstTransition.next;
        next.prev = null;
        destroyer(firstTransition);
        firstTransition = next;
      }
      if (currentTransition === null) {
        currentTransition = this;
      }
      if (this.data != null) {
        this._invoker = new Invoker(this.data);
        return this.invoke();
      }
    };
    Transition.prototype = {
      next: function(data) {
        var currentTransition;
        if (data != null) {
          this.next = new Transition(data, this);
        } else if (this.next != null) {
          this.next.invoke();
          currentTransition = this.next;
        }
        return this.next;
      },
      prev: function() {
        var currentTransition;
        if (this.prev != null) {
          this.undo();
          return currentTransition = this.prev;
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
          _.each(reloadSections, function(selector, html) {
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
          widgetsInitData: parser.getWidgets(prevElement)
        };
        nextElement = parser(html);
        return this._forward[selector] = {
          widgets: [],
          element: nextElement,
          widgetsInitData: parser.getWidgets(nextElement)
        };
      },
      _insertSections: function(forward, back) {
        var self;
        self = this;
        return _.each(forward, function(selector, data) {
          var newWidgetsInitData;
          newWidgetsInitData = parser.getWidgets(data.element);
          return self._initWidgets(newWidgetsInitData, function(widgetsList) {
            var replaceableElement, widget, _i, _j, _len, _len1, _ref, _ref1, _ref2;
            forward.widgets = widgetsList;
            replaceableElement = back[selector].element;
            if (back.widgets) {
              _ref = back.widgets;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                widget = _ref[_i];
                widget.turnOff();
              }
            } else if (back.widgetsInitData) {
              _ref1 = back.widgetsInitData;
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
    currentTransition = new Transition;
    events.on('newSectionsLoaded', function(sectionsData) {
      return currentTransition.next(sectionsData);
    });
    return {
      _getCurrentTransition: function() {
        return currentTransition;
      },
      _getFirstTransition: function() {
        return firstTransition;
      },
      _transition: Transition,
      _invoker: Invoker
    };
  });

}).call(this);
