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

  che.modules = availableModules

  che.require = (deps, callback) ->
    require deps, callback, "app", true

  che.has = (moduleName) ->
    availableModules.indexOf(moduleName) >= 0

  che.patchLoader = (require, define) ->
    load = require.load
    require.load = (context, moduleName) ->
      args = arguments
      timer = setTimeout =>
        load.apply @, args
      , 100
      if che.has moduleName
        che.require [moduleName], (module) ->
          clearTimeout timer
          define moduleName, -> module
          context.completeLoad moduleName

  che
