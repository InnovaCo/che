#### Точка входа для приложения
#
#
define (require) ->
  che = (customConfig) ->
    config = require "config"
    errorHanler = require "utils/errorHandlers/errorHandler"
    consoleHandler = require "utils/errorHandlers/console"

    # Переопределяем дефолтные параметры конфига, если надо
    config.setup customConfig if customConfig
    customConfig.modules ?= []

    # Подключаем опциональные модули
    for module in customConfig.modules when config._modules[module]?
      che.module = config._modules[module]

    # Добавляем обработчики ошибок
    errorHanler.addErrorHandler consoleHandler

    # Запускаем рантайм черхитектуры
    sections = require "sections"
    clicks = require "clicks"
    loader = require "loader"

    sections.init(config)

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
