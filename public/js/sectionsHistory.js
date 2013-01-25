(function() {

  define(['events', 'history', 'widgets', 'loader', 'dom', 'ajax', 'utils/storage', 'utils/destroyer', 'utils/widgetsData'], function(events, history, widgets, loader, dom, ajax, storage, destroyer, widgetsData) {
    /* 
    data:
      <selector>: <plainHTML>
    */

    var Invoker, Transition, loadSections, sectionsRequest, transitions;
    transitions = {
      last: null,
      current: null,
      create: function(state) {
        var isNewState, method, transition;
        state = state || {
          index: 0
        };
        if ((this.last != null) && state.index <= this.last.index) {
          transition = this.go(state.index);
          transition.update(state);
          return transition;
        } else {
          isNewState = (history.state || {}).url !== state.url;
          method = isNewState ? "pushState" : "replaceState";
          history[method](state, state.title, state.url);
          this.last = new Transition(state, this.last);
          return this.last;
        }
      },
      go: function(index) {
        var direction, _ref;
        if (!this.current) {
          return this.create();
        }
        if (index === ((_ref = this.current) != null ? _ref.index : void 0)) {
          return this.current;
        }
        direction = this.current.index < index ? "next" : "prev";
        return this.current[direction](index);
      }
    };
    Transition = function(state, last) {
      this.state = state;
      this.index = this.state.index = this.state.index || ((last != null ? last.index : void 0) + 1) || 0;
      if (last != null) {
        this.prev_transition = last;
        last.next_transition = this;
      }
      if (this.state.widgets != null) {
        this._invoker = new Invoker(this.state.widgets);
        this.invoke();
      }
      return this;
    };
    Transition.prototype = {
      update: function(state) {
        var html, isStateTheSame, selector, _ref;
        isStateTheSame = false;
        if (this.state.url === state.url) {
          _ref = state.widgets;
          for (selector in _ref) {
            html = _ref[selector];
            isStateTheSame = this.state.widgets[selector] === state.widgets[selector];
            if (!isStateTheSame) {
              break;
            }
          }
        } else {
          return;
        }
        if (!isStateTheSame) {
          state.index = this.index;
          this.state = state;
          if ((this._invoker != null) && (this.state.widgets != null)) {
            this._invoker.update(this.state.widgets);
          } else if (this.state.widgets != null) {
            this._invoker = new Invoker(this.state.widgets);
          }
          return this.invoke();
        }
      },
      next: function(to_transition) {
        if (to_transition === this.index) {
          return this;
        }
        if (this.next_transition != null) {
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
        if (this.prev_transition != null) {
          this.undo();
          if (to_transition != null) {
            return this.prev_transition.prev(to_transition);
          }
        }
      },
      undo: function() {
        var _ref;
        transitions.current = this.prev_transition;
        if ((_ref = this._invoker) != null) {
          _ref.undo();
        }
        return events.trigger("sectionsTransition:undone", this);
      },
      invoke: function() {
        var _ref;
        transitions.current = this;
        if ((_ref = this._invoker) != null) {
          _ref.run();
        }
        return events.trigger("sectionsTransition:invoked", this);
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
            this._back[selector] = dom(selector);
            this._forward[selector] = dom(html);
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
      _insertSections: function(forward, back, selectors) {
        var selector,
          _this = this;
        selectors = selectors || _.keys(back);
        if (selectors.length === 0) {
          return events.trigger("sections:inserted");
        }
        selector = selectors.shift();
        return loader.search(forward[selector], function(widgetsList) {
          var data, _i, _len, _ref, _ref1;
          _ref = widgetsData(back[selector]);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            data = _ref[_i];
            if ((_ref1 = widgets.get(data.name, data.element)) != null) {
              _ref1.turnOff();
            }
          }
          back[selector].replaceWith(forward[selector]);
          return _this._insertSections(forward, back, selectors);
        });
      }
    };
    transitions.current = transitions.create();
    sectionsRequest = null;
    loadSections = function(url, method, index) {
      if (sectionsRequest != null) {
        sectionsRequest.abort();
      }
      sectionsRequest = ajax.get({
        url: url,
        method: method
      });
      return sectionsRequest.success(function(request, state) {
        state.url = url;
        state.index = index;
        state.method = method;
        return events.trigger("sections:loaded", state);
      });
    };
    events.bind("sections:loaded", function(state) {
      storage.save("sectionsHistory", state.url, state);
      return transitions.create(state);
    });
    events.bind("pageTransition:init", function(url, method) {
      var state;
      state = storage.get("sectionsHistory", url);
      if (state != null) {
        delete state.index;
        transitions.create(state);
      }
      return loadSections(url, method);
    });
    events.bind("history:popState", function(state) {
      if (state != null) {
        transitions.go(state.index);
        return loadSections(state.url, state.method, state.index);
      }
    });
    return {
      _transitions: transitions,
      _transition: Transition,
      _invoker: Invoker
    };
  });

}).call(this);
