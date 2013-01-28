(function() {

  define([], function() {
    var Ticker;
    Ticker = function(period, callback) {
      this.period = parseInt(period, 10);
      this._callbacks = [];
      if (callback) {
        this.listen(callback);
      }
      return this;
    };
    Ticker.prototype = {
      listen: function(callback) {
        this._callbacks.push(callback);
        return this;
      },
      start: function() {
        var _this = this;
        console.log("start", this.period);
        return this._interval = setTimeout(function() {
          console.log("call setTimeout: ", _this.period, _this._callbacks);
          _this._tick();
          return _this.start();
        }, this.period);
      },
      stop: function() {
        return clearTimeout(this._interval);
      },
      _tick: function() {
        var callback, _i, _len, _ref, _results;
        _ref = this._callbacks;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          callback = _ref[_i];
          _results.push(setTimeout(callback));
        }
        return _results;
      }
    };
    return function(period, callback) {
      return new Ticker(period, callback);
    };
  });

}).call(this);
