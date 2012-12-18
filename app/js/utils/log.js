(function() {

  define(["logWriter"], function() {
    return {
      log: _log,
      info: _info,
      warn: warn,
      error: error
    };
  });

}).call(this);
