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
      return require(['dom'], function(domModule) {
        return dom = domModule;
      });
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
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var domObject;
          domObject = dom("div.test ul li a");
          expect(domObject.on).toBeFunction();
          expect(domObject.off).toBeFunction();
          expect(domObject.find).toBeFunction();
          return expect(domObject.get).toBeFunction();
        });
      });
      it('should return object with DOMelement when called with selector', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var domObject;
          domObject = dom("div.test ul li a");
          expect(_.isEqual(DOMelement, domObject[0])).toBe(true);
          expect(domObject.length).toBe(1);
          return expect(domObject instanceof dom).toBeTruthy();
        });
      });
      return it('should return empty object when called with invalidselector', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var domObject;
          domObject = dom(".selectorForNoresults");
          expect(domObject.length).toBe(0);
          return expect(domObject[0]).toBeUndefined();
        });
      });
    });
    describe('binding events', function() {
      beforeEach(function() {
        return affix("div.test ul li a");
      });
      it('should bind event handler to element', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var bindSpy;
          bindSpy = jasmine.createSpy("bindSpy");
          dom("div.test ul li a").on('click', bindSpy);
          triggerMouseEvent("click", dom("div.test ul li a").get(0));
          return expect(bindSpy).toHaveBeenCalled();
        });
      });
      return it('should delegate event handler to element', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
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
    });
    describe('unbinding events', function() {
      beforeEach(function() {
        return affix("div.test ul li a");
      });
      it('should bind and unbind event handler to element', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var bindSpy;
          bindSpy = jasmine.createSpy("bindSpy");
          dom("div.test ul li a").on('click', bindSpy);
          dom("div.test ul li a").off('click', bindSpy);
          return triggerMouseEvent("click", dom("div.test ul li a").get(0));
        });
      });
      return it('should delegate event handler to element', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var bindSpy;
          bindSpy = jasmine.createSpy("bindSpy");
          dom("div.test").on('ul li a', 'click', bindSpy);
          dom("div.test").off('ul li a', 'click', bindSpy);
          triggerMouseEvent("click", dom("div.test ul li a").get(0));
          return expect(bindSpy).not.toHaveBeenCalled();
        });
      });
    });
    return describe('finding objects', function() {
      var DOMelement;
      DOMelement = null;
      beforeEach(function() {
        var fixture;
        fixture = affix("div.test ul li a#test");
        return DOMelement = document.getElementById('test');
      });
      it('should find element inside', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var foundObj, obj;
          obj = dom('div.test');
          foundObj = obj.find('a#test');
          return expect(_.isEqual(foundObj.get(0), DOMelement)).toBeTruthy();
        });
      });
      return it('find should return instance of domQuery', function() {
        waitsFor(function() {
          return dom != null;
        });
        return runs(function() {
          var obj;
          obj = dom('div.test');
          return expect(obj instanceof dom).toBeTruthy();
        });
      });
    });
  });

}).call(this);
