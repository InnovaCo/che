(function() {

  describe('sectionsHistory module', function() {
    var ajax, browserHistory, events, history, storage, widgets;
    history = null;
    events = null;
    widgets = null;
    storage = null;
    browserHistory = null;
    ajax = null;
    require(['sectionsHistory', 'events', 'widgets', 'utils/storage', 'history', 'ajax'], function(historyModule, eventsModule, widgetsModule, storageModule, browserHistoryModule, ajaxModule) {
      history = historyModule;
      events = eventsModule;
      widgets = widgetsModule;
      storage = storageModule;
      browserHistory = browserHistoryModule;
      return ajax = ajaxModule;
    });
    history = null;
    beforeEach(function() {
      history._transition.current = null;
      return waitsFor(function() {
        return history != null;
      });
    });
    describe('creating transitions', function() {
      it('should create transition and set firstTransition and currentTransition', function() {
        var nextTransition, transition;
        transition = new history._transition({
          index: 1
        });
        nextTransition = new history._transition({
          widgets: {}
        });
        expect(history._transition.last).toBe(nextTransition);
        return expect(history._transition.current).toBe(nextTransition);
      });
      it('should create transition and set previous created as .prev', function() {
        var nextTransition, transition;
        transition = new history._transition({});
        nextTransition = new history._transition({});
        expect(transition).toBe(nextTransition.prev_transition);
        return expect(transition.next_transition).toBe(nextTransition);
      });
      return it('should destroy first transition after 10 new created', function() {
        var firstTransition, i, transition, _i;
        firstTransition = new history._transition({
          widgets: {}
        });
        transition = firstTransition;
        for (i = _i = 1; _i < 10; i = ++_i) {
          transition = new history._transition({
            widgets: {}
          });
        }
        return expect(firstTransition).toBeEmpty();
      });
    });
    describe('invoking transitions', function() {
      var reload_sections, update_sections;
      reload_sections = {
        widgets: {
          "#one": "<div id='three'><span>hello</span></div>",
          "#two": "<div id='four'><span>world</span></div>"
        }
      };
      update_sections = {
        widgets: {
          "#three": "<div id='three'><span>Hello</span></div>",
          "#four": "<div id='four'><span>Universe</span></div>"
        }
      };
      beforeEach(function() {
        affix("div#one span.section");
        affix("div#two span.section");
        history._transition.last = null;
        return history._transition.current = null;
      });
      it('should replace sections', function() {
        var transition;
        transition = new history._transition(reload_sections);
        expect($("#one").length).toBe(0);
        expect($("#two").length).toBe(0);
        expect($("#three span").text()).toBe("hello");
        return expect($("#four span").text()).toBe("world");
      });
      return it('should replace sections and undo', function() {
        var transition;
        transition = new history._transition(reload_sections);
        expect($("#one").length).toBe(0);
        expect($("#two").length).toBe(0);
        expect($("#three span").text()).toBe("hello");
        expect($("#four span").text()).toBe("world");
        transition.undo();
        expect($("#one").length).toBe(1);
        expect($("#two").length).toBe(1);
        expect($("#three").length).toBe(0);
        return expect($("#four").length).toBe(0);
      });
    });
    describe('updating transitions', function() {
      var reload_sections, update_sections;
      reload_sections = {
        widgets: {
          "#one": "<div id='three'><span>hello</span></div>",
          "#two": "<div id='four'><span>world</span></div>"
        }
      };
      update_sections = {
        widgets: {
          "#one": "<div id='three'><span>Hello</span></div>",
          "#two": "<div id='four'><span>Universe</span></div>"
        }
      };
      beforeEach(function() {
        affix("div#one span.section");
        affix("div#two span.section");
        history._transition.last = null;
        return history._transition.current = null;
      });
      it("should update sections", function() {
        var transition;
        transition = new history._transition(reload_sections);
        expect($("#one").length).toBe(0);
        expect($("#two").length).toBe(0);
        expect($("#three span").text()).toBe("hello");
        expect($("#four span").text()).toBe("world");
        transition.update(update_sections);
        expect($("#one").length).toBe(0);
        expect($("#two").length).toBe(0);
        expect($("#three span").text()).toBe("Hello");
        return expect($("#four span").text()).toBe("Universe");
      });
      return it("shouldn't update sections", function() {
        var transition;
        transition = new history._transition(reload_sections);
        expect($("#one").length).toBe(0);
        expect($("#two").length).toBe(0);
        expect($("#three span").text()).toBe("hello");
        expect($("#four span").text()).toBe("world");
        transition.update(_.extend({}, update_sections, {
          url: "url"
        }));
        expect($("#one").length).toBe(0);
        expect($("#two").length).toBe(0);
        expect($("#three span").text()).toBe("hello");
        return expect($("#four span").text()).toBe("world");
      });
    });
    describe('creating invoke objects', function() {
      var reload_sections;
      reload_sections = {
        widgets: {
          "#one": "<div id='three'><span>hello</span></div>",
          "#two": "<div id='four' class='widgets' data-js-modules='gradient'><span>world</span></div>"
        }
      };
      beforeEach(function() {
        affix("div#one span.section");
        affix("div#two.widgets[data-js-modules=gradient] span.section");
        history._transition.last = null;
        return history._transition.current = null;
      });
      it("should create invoke object if sections are specified", function() {
        var transition;
        transition = new history._transition(reload_sections);
        return expect(transition._invoker).toBeDefined();
      });
      it("shouldn't create invoke object 'cause sections arn't specified", function() {
        var transition;
        transition = new history._transition({});
        return expect(transition._invoker).not.toBeDefined();
      });
      it("invoker shouldn't contain data for forward and backward transitions right after initialization", function() {
        var invoker;
        invoker = new history._invoker(reload_sections.widgets);
        expect(invoker._back).toBe(null);
        expect(invoker._forward).toBe(null);
        expect(invoker._is_applied).toBe(false);
        return expect(invoker._is_sections_updated).toBe(false);
      });
      it("invoker should contain data for forward and backward transitions after it have ran", function() {
        var invoker;
        invoker = new history._invoker(reload_sections.widgets);
        invoker.run();
        expect(invoker._back).toBeDefined();
        expect(invoker._back["#one"]).toBeDefined();
        expect(invoker._back["#two"]).toBeDefined();
        expect(invoker._back["#one"].element).toBeDefined();
        expect(invoker._back["#one"].element[0].innerHTML.toLowerCase()).toBe("<span class=\"section\"></span>");
        expect(invoker._back["#one"].element[0].getAttribute("id")).toBe("one");
        expect(invoker._back["#two"].widgetsInitData).toBeDefined();
        expect(invoker._forward).toBeDefined();
        expect(invoker._forward["#one"]).toBeDefined();
        expect(invoker._forward["#two"]).toBeDefined();
        expect(invoker._forward["#one"].element[0].innerHTML.toLowerCase()).toBe("<span>hello</span>");
        expect(invoker._forward["#one"].element[0].getAttribute("id")).toBe("three");
        return expect(invoker._forward["#one"].element).toBeDefined();
      });
      it("invoker contain data for widgets turning off", function() {
        var invoker;
        invoker = new history._invoker(reload_sections.widgets);
        invoker.run();
        expect(invoker._back["#two"].widgetsInitData).toBeDefined();
        return expect(invoker._back["#two"].widgetsInitData[0].name).toBe('gradient');
      });
      return it("invoker should change sections", function() {
        var invoker;
        invoker = new history._invoker(reload_sections.widgets);
        invoker.run();
        waits(500);
        return runs(function() {
          expect($("#one").length).toBe(0);
          expect($("#two").length).toBe(0);
          expect($("#three span").text()).toBe("hello");
          return expect($("#four span").text()).toBe("world");
        });
      });
    });
    describe('initilize widgets', function() {
      var reload_sections;
      reload_sections = {
        widgets: {
          "#one": "<div id='three' class='widgets' data-js-modules='rotation'><span>hello</span></div>",
          "#two": "<div id='four' class='widgets' data-js-modules='gradient, opacity'><span>world</span></div>"
        }
      };
      beforeEach(function() {
        affix("div#one.widgets[data-js-modules=gradient] span.section");
        affix("div#two.widgets[data-js-modules=opacity] span.section");
        history._transition.last = null;
        history._transition.current = null;
        return spyOn(widgets, "create").andCallThrough();
      });
      it("should init all widgets from new sections", function() {
        var allDone, invoker;
        allDone = false;
        events.bind("sections:inserted", function() {
          return allDone = true;
        });
        invoker = new history._invoker(reload_sections.widgets);
        invoker.run();
        waitsFor(function() {
          return allDone === true;
        });
        return runs(function() {
          expect(widgets.create.calls.length).toBe(3);
          expect(widgets.create.calls[0].args[0]).toBe("rotation");
          expect(widgets.create.calls[0].args[1]).toBeDomElement();
          expect(widgets.create.calls[0].args[2]).toBeFunction();
          expect(widgets.create.calls[1].args[0]).toBe("gradient");
          expect(widgets.create.calls[1].args[1]).toBeDomElement();
          expect(widgets.create.calls[1].args[2]).toBeFunction();
          expect(widgets.create.calls[2].args[0]).toBe("opacity");
          expect(widgets.create.calls[2].args[1]).toBeDomElement();
          return expect(widgets.create.calls[2].args[2]).toBeFunction();
        });
      });
      return it("should turn off all widgets from old sections", function() {
        var allwidgetsReady;
        allwidgetsReady = false;
        widgets.create("gradient", $("#one")[0]);
        widgets.create("opacity", $("#two")[0]);
        require(["widgets/gradient", "widgets/rotation", "widgets/opacity"], function() {
          return allwidgetsReady = true;
        });
        waitsFor(function() {
          return allwidgetsReady === true;
        });
        return runs(function() {
          var allDone, gradient_widget, invoker, opacity_widget;
          gradient_widget = widgets.get("gradient", $("#one")[0]);
          opacity_widget = widgets.get("opacity", $("#two")[0]);
          allDone = false;
          events.bind("sections:inserted", function() {
            return allDone = true;
          });
          invoker = new history._invoker(reload_sections.widgets);
          invoker.run();
          waitsFor(function() {
            return allDone === true;
          });
          return runs(function() {
            expect(gradient_widget._isOn).toBeFalsy();
            return expect(opacity_widget._isOn).toBeFalsy();
          });
        });
      });
    });
    describe('saving transition sections to localStorage', function() {
      var reload_sections;
      reload_sections = {
        url: window.location.origin,
        title: "test Title",
        widgets: {
          "#one": "<div id='three' class='widgets' data-js-modules='rotation'><span>hello</span></div>",
          "#two": "<div id='four' class='widgets' data-js-modules='gradient, opacity'><span>world</span></div>"
        }
      };
      beforeEach(function() {
        storage.remove("sectionsHistory", window.location.origin);
        affix("div#one span.section");
        spyOn(browserHistory, "pushState");
        history._transition.last = null;
        return history._transition.current = null;
      });
      it("should save sections data to localstorage", function() {
        var allDone;
        allDone = false;
        events.bind("sectionsTransition:invoked", function() {
          return allDone = true;
        });
        events.trigger("sections:loaded", reload_sections);
        waitsFor(function() {
          return allDone === true;
        });
        return runs(function() {
          var savedState;
          savedState = storage.get("sectionsHistory", window.location.origin);
          expect(savedState.widgets).toBeDefined();
          expect(savedState.title).toBe(reload_sections.title);
          expect(savedState.widgets["#one"]).toBe(reload_sections.widgets["#one"]);
          return expect(savedState.widgets["#two"]).toBe(reload_sections.widgets["#two"]);
        });
      });
      return it("should update sections data in localstorage", function() {
        var allDone;
        allDone = false;
        events.bind("sectionsTransition:invoked", function() {
          return allDone = true;
        });
        storage.save("sectionsHistory", reload_sections.url, reload_sections);
        events.trigger("sections:loaded", {
          url: window.location.origin,
          title: "second test Title",
          widgets: {
            "#one": "<div></div>"
          }
        });
        waitsFor(function() {
          return allDone === true;
        });
        return runs(function() {
          var savedState;
          savedState = storage.get("sectionsHistory", window.location.origin);
          expect(savedState.widgets).toBeDefined();
          expect(savedState.title).toBe("second test Title");
          expect(savedState.widgets["#one"]).toBe("<div></div>");
          return expect(savedState.widgets["#two"]).not.toBeDefined();
        });
      });
    });
    describe('loading transition sections', function() {
      var reload_sections;
      reload_sections = null;
      beforeEach(function() {
        reload_sections = {
          url: window.location.origin,
          title: "test Title",
          widgets: {
            "#one": "<div id='three' class='widgets' data-js-modules='rotation'><span>hello</span></div>"
          }
        };
        affix("div#one span.section");
        return spyOn(ajax, "get");
      });
      it("should update sections from server, when traversing history", function() {
        var allDone;
        allDone = false;
        events.bind("sectionsTransition:invoked", function() {
          return allDone = true;
        });
        events.trigger("history:popState", {
          url: window.location.origin,
          title: "second test Title",
          widgets: {
            "#one": "<div></div>"
          }
        });
        waitsFor(function() {
          return allDone === true;
        });
        return runs(function() {
          var requestInfo;
          requestInfo = ajax.get.mostRecentCall.args[0];
          expect(ajax.get).toHaveBeenCalled();
          return expect(requestInfo.url).toBe(window.location.origin);
        });
      });
      it("should load sections from server, when going forward", function() {
        var allDone;
        allDone = false;
        events.bind("sectionsTransition:invoked", function() {
          return allDone = true;
        });
        storage.save("sectionsHistory", reload_sections.url, reload_sections);
        events.trigger("pageTransition:init", window.location.origin, {});
        waitsFor(function() {
          return allDone === true;
        });
        return runs(function() {
          var requestInfo;
          requestInfo = ajax.get.mostRecentCall.args[0];
          expect(ajax.get).toHaveBeenCalled();
          return expect(requestInfo.url).toBe(window.location.origin);
        });
      });
      return it("should load sections from localstorage, when going forward, and then update from server", function() {
        var allDone;
        allDone = false;
        events.bind("sectionsTransition:invoked", function() {
          return allDone = true;
        });
        spyOn(storage, "get").andCallThrough();
        storage.save("sectionsHistory", reload_sections.url, reload_sections);
        events.trigger("pageTransition:init", window.location.origin, {});
        waitsFor(function() {
          return allDone === true;
        });
        return runs(function() {
          var requestInfo, storageGetInfo;
          requestInfo = ajax.get.mostRecentCall.args[0];
          storageGetInfo = storage.get.mostRecentCall.args;
          expect(ajax.get).toHaveBeenCalled();
          expect(requestInfo.url).toBe(window.location.origin);
          expect(storage.get).toHaveBeenCalled();
          expect(storageGetInfo[0]).toBe("sectionsHistory");
          return expect(storageGetInfo[1]).toBe(window.location.origin);
        });
      });
    });
    return describe('getting state from history', function() {});
  });

}).call(this);
