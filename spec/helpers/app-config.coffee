require.config
  baseUrl: "build"
  paths:
    "che": "../public/js/app"
    "underscore": "../node_modules/underscore/underscore-min"
  shim:
    underscore:
      exports: "_"
