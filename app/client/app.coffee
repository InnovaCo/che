#### Точка входа для приложения
#
#

@che = (customConfig) ->
  requirejs ['config'], (config) ->
    # Переопределяем дефолтные параметры конфига, если надо
    config.setup customConfig if customConfig

    # Подключаем опциональные модули
    customConfig.modules ?= []
    for module in customConfig.modules when config._modules[module]?
      che.module = config._modules[module]

  # Добавляем обработчики ошибок
  requirejs ['utils/errorHandlers/errorHandler', 'utils/errorHandlers/console'], (errorHanler, consoleHandler) ->
    errorHanler.addErrorHandler consoleHandler

  # Подключает модули 'loader', 'lib/domReady'
  requirejs ['loader', 'clicks', 'sections'], (loader) ->