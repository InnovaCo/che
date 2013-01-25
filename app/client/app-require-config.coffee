#### Базовый конфиг для приложения
#
require.config
  # указываем место относительно которого requirejs грузит скрипты
  baseUrl: "public/js"

  paths:
    "underscore": "lib/underscore"

  shim:
    "underscore":
      exports: "_"