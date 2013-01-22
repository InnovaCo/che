(function() {

  define(['events', 'history', 'widgets', 'dom', 'ajax', 'utils/storage', 'utils/destroyer', 'utils/widgetsData'], function(events, history, widgets, dom, ajax, storage, destroyer, widgetsData) {
    /* 
    data:
      <selector>: <plainHTML>
    */

    var Invoker, Transition, initSections, loadSections, sectionsRequest;
    Transition = function(data) {
      var direction, transition, _base, _ref;
      data = data || {
        index: 0
      };
      if ((Transition.last != null) && data.index <= Transition.last.index) {
        direction = null;
        if (data.index === Transition.current.index) {
          Transition.current.update(data);
        } else if (Transition.current.index < data.index) {
          direction = "next";
        } else if (data.index < Transition.current.index) {
          direction = "prev";
        }
        if (direction != null) {
          transition = typeof (_base = Transition.current)[direction] === "function" ? _base[direction](data.index) : void 0;
          transition.update(data);
        }
        return Transition.current;
      } else {
        this.data = data;
        this.index = this.data.index = this.data.index || (((_ref = Transition.last) != null ? _ref.index : void 0) + 1) || 0;
        this.prev_transition = Transition.last;
        if (Transition.last != null) {
          Transition.last.next_transition = this;
        }
        Transition.last = this;
        if (this.data.widgets != null) {
          this._invoker = new Invoker(this.data.widgets);
          this.invoke();
        }
        return this;
      }
    };
    Transition.first = null;
    Transition.last = null;
    Transition.depth = null;
    Transition.current = null;
    Transition.prototype = {
      update: function(data) {
        var html, isDataTheSame, selector, _ref;
        isDataTheSame = false;
        if (this.data.url === data.url) {
          _ref = data.widgets;
          for (selector in _ref) {
            html = _ref[selector];
            isDataTheSame = this.data.widgets[selector] === data.widgets[selector];
            if (!isDataTheSame) {
              break;
            }
          }
        } else {
          return;
        }
        if (!isDataTheSame) {
          data.index = this.index;
          this.data = data;
          if ((this._invoker != null) && (this.data.widgets != null)) {
            this._invoker.update(this.data.widgets);
          } else if (this.data.widgets != null) {
            this._invoker = new Invoker(this.data.widgets);
          }
          if (Transition.current === this) {
            return this.invoke();
          }
        }
      },
      next: function(to_transition) {
        if (to_transition === this.index) {
          return this;
        }
        if (this.next != null) {
          this.next_transition.invoke();
          if (to_transition != null) {
            return this.next_transition.next(to_transition);
          }
        }
      },
      prev: function(to_transition) {
        if (to_transition === this.index) {
          return this;
        }
        if (this.prev != null) {
          this.undo();
          if (to_transition != null) {
            return this.prev_transition.prev(to_transition);
          }
        }
      },
      undo: function() {
        var _ref;
        Transition.current = this.prev_transition;
        if ((_ref = this._invoker) != null) {
          _ref.undo();
        }
        return events.trigger("sectionsTransition:undone");
      },
      invoke: function() {
        var _ref;
        Transition.current = this;
        if ((_ref = this._invoker) != null) {
          _ref.run();
        }
        return events.trigger("sectionsTransition:invoked");
      }
    };
    Invoker = function(reloadSections) {
      this.reloadSections = reloadSections;
      this._back = null;
      this._forward = null;
      this._is_applied = false;
      return this._is_sections_updated = false;
    };
    Invoker.prototype = {
      update: function(sections) {
        this.reloadSections = sections;
        return this._is_sections_updated = false;
      },
      run: function() {
        var html, selector, _ref;
        if (this._is_applied) {
          this.undo();
        }
        if (!this._is_sections_updated || !this._forward || !this._back) {
          this._back = {};
          this._forward = {};
          _ref = this.reloadSections;
          for (selector in _ref) {
            html = _ref[selector];
            this._reloadSectionInit(selector, html);
          }
          this._is_sections_updated = true;
        }
        this._insertSections(this._forward, this._back);
        return this._is_applied = true;
      },
      undo: function() {
        if (!this._forward && !this._back || this._is_applied !== true) {
          return false;
        }
        this._insertSections(this._back, this._forward);
        return this._is_applied = false;
      },
      _reloadSectionInit: function(selector, html) {
        var nextElement, prevElement;
        prevElement = dom(selector);
        this._back[selector] = {
          element: prevElement,
          widgetsInitData: widgetsData(prevElement)
        };
        nextElement = dom(html);
        return this._forward[selector] = {
          element: nextElement
        };
      },
      _insertSections: function(forward, back, sectionsList) {
        var data, next, sectionsToInsert, selector,
          _this = this;
        if (!sectionsList) {
          sectionsToInsert = [];
          for (selector in forward) {
            data = forward[selector];
            sectionsToInsert.push({
              forward: forward[selector],
              back: back[selector]
            });
          }
          return this._insertSections(forward, back, sectionsToInsert);
        } else if (sectionsList.length === 0) {
          return events.trigger("sections:inserted");
        } else {
          next = sectionsList.shift();
          next.forward.widgetsInitData = widgetsData(next.forward.element);
          return this._initWidgets(next.forward.widgetsInitData, function(widgetsList) {
            var replaceableElement, widgetData, _i, _len, _ref, _ref1;
            next.forward.widgets = widgetsList;
            replaceableElement = next.back.element;
            if (next.back.widgetsInitData) {
              _ref = next.back.widgetsInitData;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                widgetData = _ref[_i];
                if ((_ref1 = widgets.get(widgetData.name, widgetData.element)) != null) {
                  _ref1.turnOff();
                }
              }
            }
            replaceableElement.replaceWith(next.forward.element);
            return _this._insertSections(forward, back, sectionsList);
          });
        }
      },
      _initWidgets: function(widgetsDataList, ready) {
        var data, list, widgetsCount, _i, _len, _results;
        widgetsCount = _.keys(widgetsDataList).length;
        list = [];
        if (widgetsCount === 0) {
          return ready(list);
        }
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
    sectionsRequest = null;
    loadSections = function(url, index) {
      if (sectionsRequest != null) {
        sectionsRequest.abort();
      }
      sectionsRequest = ajax.get({
        url: url
      });
      return sectionsRequest.success(function(request, state) {
        state.url = url;
        state.index = index;
        return events.trigger("sections:loaded", state);
      });
    };
    initSections = function(state) {
      var history_state;
      history_state = history.state || {};
      if (history_state.url !== state.url) {
        history.pushState(state, state.title, state.url);
      }
      return new Transition(state);
    };
    events.bind("pageTransition:init", function(url, data) {
      var lastStateIndex, state;
      state = storage.get("sectionsHistory", url);
      lastStateIndex = Transition.last.index + 1;
      if (state != null) {
        state.index = lastStateIndex;
        initSections(state);
      }
      return loadSections(url, lastStateIndex);
    });
    events.bind("history:popState", function(state) {
      new Transition(state);
      if (state != null) {
        return loadSections(state.url, state.index);
      }
    });
    events.bind("sections:loaded", function(state) {
      var save_state;
      save_state = _.clone(state);
      delete save_state.index;
      storage.save("sectionsHistory", state.url, save_state);
      return initSections(state);
    });
    return {
      _transition: Transition,
      _invoker: Invoker
    };
  });

}).call(this);
