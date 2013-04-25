#### Базовый конфиг для приложения
#
require.config
  # указываем место относительно которого requirejs грузит скрипты
  baseUrl: "public/js"

  shim:
    "underscore":
      exports: "_"
      
define "underscore", ->
  return _