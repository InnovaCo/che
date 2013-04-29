#### *module* errorHandlers/errorHandler
#
# Является хранилищем для произвольного набора обработчиков ошибок.
# На данный момент обрабатываются следующие типы ошибок путём вызова одноименного метода в хэндлерах:
# * *sectionLoadError* - инициализируется модулем sections в случае ошибки при загрузке секции(й) с сервера
#
define () ->
  errorHandlers = []

  _addErrorHandler = (errorHandler) ->
    errorHandlers.push errorHandler

  _processError = (errorType, data = []) ->
    handler[errorType] data for handler in errorHandlers when handler[errorType] != undefined

  # ----------------------------------
  # Module API
  # ----------------------------------
  return {
    addErrorHandler: _addErrorHandler
    processError: _processError
  }