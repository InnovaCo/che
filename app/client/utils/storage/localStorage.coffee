#### *module* localStorage
#
#
#---
# Модуль для хранения временных данных в local/session storage
#
define ["utils/storage/abstract"], (Storage) ->

  class LocalStorage extends Storage
    _localStorage = window.localStorage
    _sessionStorage = window.sessionStorage

    constructor: () ->
      if not isLocalStorageAvailable()
        return false
      super

    @get = (varName) ->
      return _localStorage.getItem(varName) ? _sessionStorage.getItem(varName)

    @save = (varName, value, isSessionOnly) ->
      _storage = if isSessionOnly then _sessionStorage else _localStorage
      @remove varName        # Чистим на всякий случай оба storage, чтобы не осталось дубликатов
      try
        _storage.setItem varName, value
        return on
      catch err
        # @todo: log error
        return off

    @remove = (varName) ->
      _localStorage.removeItem varName
      _sessionStorage.removeItem varName
      on

    @getKeys = (isSessionOnly) ->
      _storage = if isSessionOnly then _sessionStorage else _localStorage
      objToReturn = {}
      for item in [0.._storage.length]
        objToReturn[_storage.key(item)] = _storage.get _storage.key(item)

      return objToReturn

    # Вспомогательные методы
    isLocalStorageAvailable = () ->
      console.log _localStorage, window.localStorage
      return typeof _localStorage isnt "undefined"

  return new LocalStorage()
