#### Базовый конфиг для приложения
#
require.config
  # указываем место относительно которого requirejs грузит скрипты
  baseUrl: "public/js"

  paths:
    "underscore": "lib/underscore-min"

  shim:
    "underscore":
      exports: "_"