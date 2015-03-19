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

  # Объявляем минимально необходимый публичный интерфейс.
  che.config = require "config"
  che.events = require "events"
  che.loader = require "loader"
  che.history = require "history"

  che.dom = require "dom"
  che.ajax = require "ajax"
  che.domReady = require "lib/domReady"

  che.clicks = require "clicks"
  che.forms = require "clicks/forms"
  che.anchors = require "clicks/anchors"
  che.sectionsLoader = require "sections/loader"

  che.clicksPreprocessor = require "utils/preprocessors/clicks"
  che.scrollPreprocessor = require "utils/preprocessors/scroll"

  che
