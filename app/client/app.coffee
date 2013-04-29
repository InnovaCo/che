#### Точка входа для приложения
#
#

@che = (customConfig) ->

  # Переопределяем дефолтные параметры конфига, если надо
  (
    requirejs ['config'], (config) ->
      config.setup customConfig
  ) if customConfig

  # Подключает модули 'loader', 'lib/domReady'
  requirejs ['loader', 'clicks', 'sections'], (loader) ->