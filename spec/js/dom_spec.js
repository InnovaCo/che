(function() {

  describe('dom module', function() {
    var dom, triggerMouseEvent;
    dom = null;
    triggerMouseEvent = null;
    beforeEach(function() {
      triggerMouseEvent = function(eventName, element) {
        var event;
        if (document.createEvent) {
          event = document.createEvent("MouseEvents");
          event.initEvent(eventName, true, true);
        } else {
          event = document.createEventObject();
          event.eventType = eventName;
        }
        event.eventName = eventName;
        event.memo = {};
        if (document.createEvent) {
          return element.dispatchEvent(event);
        } else {
          return element.fireEvent("on" + event.eventType, event);
        }
      };
      require(['dom'], function(domModule) {
        return dom = domModule;
      });
      waitsFor(function() {
        return dom != null;
      });
      return runs(function() {});
    });
    describe('initialize dom object', function() {
      var DOMelement;
      DOMelement = null;
      beforeEach(function() {
        var fixture;
        fixture = affix("div.test ul li a#test");
        return DOMelement = document.getElementById('test');
      });
      it('should have "on", "off", "find", "get" functions', function() {
        var domObject;
        domObject = dom("div.test ul li a");
        expect(domObject.on).toBeFunction();
        expect(domObject.off).toBeFunction();
        expect(domObject.find).toBeFunction();
        return expect(domObject.get).toBeFunction();
      });
      it('should return object with DOMelement when called with selector', function() {
        var domObject;
        domObject = dom("div.test ul li a");
        expect(_.isEqual(DOMelement, domObject[0])).toBe(true);
        expect(domObject.length).toBe(1);
        return expect(domObject instanceof dom).toBeTruthy();
      });
      return it('should return empty object when called with invalidselector', function() {
        var domObject;
        domObject = dom(".selectorForNoresults");
        expect(domObject.length).toBe(0);
        return expect(domObject[0]).toBeUndefined();
      });
    });
    describe('binding events', function() {
      beforeEach(function() {
        return affix("div.test ul li a");
      });
      it('should bind event handler to element', function() {
        var bindSpy;
        bindSpy = jasmine.createSpy("bindSpy");
        dom("div.test ul li a").on('click', bindSpy);
        triggerMouseEvent("click", dom("div.test ul li a").get(0));
        return expect(bindSpy).toHaveBeenCalled();
      });
      return it('should delegate event handler to element', function() {
        var bindSpy;
        bindSpy = jasmine.createSpy("bindSpy");
        dom("div.test").on('ul li a', 'click', bindSpy);
        triggerMouseEvent("click", dom("div.test ul li a").get(0));
        waitsFor(function() {
          return 0 < bindSpy.calls.length;
        });
        return runs(function() {
          return expect(bindSpy).toHaveBeenCalled();
        });
      });
    });
    describe('unbinding events', function() {
      beforeEach(function() {
        return affix("div.test ul li a");
      });
      it('should bind and unbind event handler to element', function() {
        var bindSpy;
        bindSpy = jasmine.createSpy("bindSpy");
        dom("div.test ul li a").on('click', bindSpy);
        dom("div.test ul li a").off('click', bindSpy);
        triggerMouseEvent("click", dom("div.test ul li a").get(0));
        return expect(bindSpy).not.toHaveBeenCalled();
      });
      return it('should delegate event handler to element', function() {
        var bindSpy;
        bindSpy = jasmine.createSpy("bindSpy");
        dom("div.test").on('ul li a', 'click', bindSpy);
        dom("div.test").off('ul li a', 'click', bindSpy);
        triggerMouseEvent("click", dom("div.test ul li a").get(0));
        return expect(bindSpy).not.toHaveBeenCalled();
      });
    });
    describe('finding objects', function() {
      var DOMelement;
      DOMelement = null;
      beforeEach(function() {
        var fixture;
        fixture = affix("div.test ul li a#test");
        return DOMelement = document.getElementById('test');
      });
      it('should find element inside', function() {
        var foundObj, obj;
        obj = dom('div.test');
        foundObj = obj.find('a#test');
        return expect(_.isEqual(foundObj.get(0), DOMelement)).toBeTruthy();
      });
      return it('find should return instance of domQuery', function() {
        var obj;
        obj = dom('div.test');
        return expect(obj instanceof dom).toBeTruthy();
      });
    });
    return describe('loader API', function() {
      var domReady;
      domReady = null;
      beforeEach(function() {
        domReady = null;
        require(['lib/domReady'], function(domReadyModule) {
          return domReady = domReadyModule;
        });
        return waitsFor(function() {
          return domReady !== null;
        });
      });
      it('should call return dom module, when required as loader', function() {
        var module;
        module = null;
        require(['dom!'], function(dom) {
          return module = dom;
        });
        waitsFor(function() {
          return module != null;
        });
        return runs(function() {
          return expect(module).toBe(dom);
        });
      });
      return it('should call onload with null in build mode', function() {
        var onload;
        onload = jasmine.createSpy('onload');
        dom.load("onload", null, onload, {
          isBuild: true
        });
        expect(onload).toHaveBeenCalled();
        return expect(onload.mostRecentCall.args[0]).toBe(dom);
      });
    });
  });

}).call(this);
