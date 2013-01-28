(function() {

  require.config({
    baseUrl: "public/js",
    paths: {
      "underscore": "lib/underscore"
    },
    shim: {
      "underscore": {
        exports: "_"
      }
    }
  });

}).call(this);
