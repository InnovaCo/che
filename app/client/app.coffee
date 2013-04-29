#### Точка входа для приложения
#
#

@che = (customConfig) ->

  # Переопределяем дефолтные параметры конфига, если надо
  (
    requirejs ['config'], (config) ->
      config.setup customConfig
  ) if customConfig
  
  # Добавляем обработчики ошибок
  requirejs ['utils/errorHandlers/errorHandler', 'utils/errorHandlers/console'], (errorHanler, consoleHandler) ->
    errorHanler.addErrorHandler consoleHandler

  # Подключает модули 'loader', 'lib/domReady'
  requirejs ['loader', 'clicks', 'sections'], (loader) ->