require.config
  baseUrl: "build"
  paths:
    "che": "app"
    "lib/domReady": "../app/client/lib/domReady"
    "lib/serialize": "../app/client/lib/serialize"
    "underscore": "../node_modules/underscore/underscore-min"
  shim:
    underscore:
      exports: "_"
