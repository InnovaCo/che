#### Точка входа для приложения
#
#
define (require) ->
  che = (customConfig) ->
    require ['config'], (config) ->
      # Переопределяем дефолтные параметры конфига, если надо
      config.setup customConfig if customConfig

      # Подключаем опциональные модули
      customConfig.modules ?= []
      for module in customConfig.modules when config._modules[module]?
        che.module = config._modules[module]

    # Добавляем обработчики ошибок
    require ['utils/errorHandlers/errorHandler', 'utils/errorHandlers/console'], (errorHanler, consoleHandler) ->
      errorHanler.addErrorHandler consoleHandler

    # Подключает модули 'loader', 'lib/domReady'
    require ['loader', 'clicks', 'sections']

  che.load = (name, req, onload) ->
    module = require name
    if module
      onload module
    else
      onload.error "che missing #{name}"

  che
