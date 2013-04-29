#### *module* errorHandlers/console
#
# Логирование ошибок в консоль
#
define () ->

  return {
    sectionLoadError: (data) ->
      console.error "SECTION LOAD ERROR: ", data.state, data.errorCode, data.errorMessage
  }