#### *module* storage
#
#
#---
# Модуль для хранения временных данных, нужных другим модулям.
#
define 'storage', () ->
  #
  # Работа с самим LocalStorage и SessionStorage
  #
  _localStorage = window.localStorage
  _sessionStorage = window.sessionStorage

  getFromLocalStorage = (varName) ->
    return _localStorage.getItem(varName) ? _sessionStorage.getItem(varName)

  saveToLocalStorage = (varName, value, isSessionOnly) ->
    _storage = if isSessionOnly then _sessionStorage else _localStorage
    removeFromLocalStorage varName        # Чистим на всякий случай оба storage, чтобы не осталось дубликатов
    try
      _storage.setItem varName, value
      return on
    catch err
      # @todo: log error
      return off

  removeFromLocalStorage = (varName) ->
    _localStorage.removeItem varName
    _sessionStorage.removeItem varName
    on


  getKeysFromLocalStorage = (isSessionOnly) ->
    _storage = if isSessionOnly then _sessionStorage else _localStorage
    objToReturn = {}
    for item in [0.._storage.length]
      objToReturn[_storage.key(item)] = _storage.get _storage.key(item)

    return objToReturn

  #
  # Fallback — работа с куками
  #
  # A complete cookies reader/writer framework with full unicode support.
  # Использованы куски кода вот отсюда:
  # https://developer.mozilla.org/en-US/docs/DOM/document.cookie
  getFromCookie = (varName) ->
    return null if not varName or not hasItemInCookie(varName)
    unescape document.cookie.replace(new RegExp("(?:^|.*;\\s*)" + escape(varName).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*((?:[^;](?!;))*[^;]?).*"), "$1")


  saveToCookie = (varName, value, isSessionOnly) ->
    return false if not varName or /^(?:expires|max\-age|path|domain|secure)$/i.test(varName)
    path = "/"
    expires = "; expires=Tue, 19 Jan 2038 03:14:07 GMT" if not isSessionOnly
    document.cookie = "#{escape(varName)}=#{escape(value)};path=#{path}" + expires

  
  removeFromCookie = (varName) ->
    return  if not varName or not hasItemInCookie(varName)
    document.cookie = escape(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + ((if sPath then "; path=" + sPath else ""))

  hasItemInCookie: (sKey) ->
    (new RegExp("(?:^|;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test document.cookie


  # Вспомогательные методы
  isLocalStorageAvailable = () ->
    return typeof _localStorage isnt "undefined";

  createVarName = (moduleName, varName) ->
    "#{moduleName}/#{varName}"

    removeItem: (sKey, sPath) ->

  getKeysFromCookies =  ->
    keys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/)
    objToReturn = {}
    for index in [0..keys.length]
      objToReturn[keys(index)] = unescape getFromCookie keys(index)

    objToReturn

  # Делаем открытый API, чтобы было удобно отлаживать и тестировать
  window.inn.storage = 
    save: (moduleName, varName, value, isSessionOnly) ->
      return off if typeof value isnt "string"
      return saveToLocalStorage( createVarName(moduleName, varName), value, isSessionOnly) if _isLocalStorageAvailable()
      return saveToCookie createVarName(moduleName, varName, isSessionOnly), value

    get: (moduleName, varName) ->
      return getFromLocalStorage(createVarName moduleName, varName) if _isLocalStorageAvailable()
      return getFromCookie createVarName moduleName, varName

    remove: (moduleName, varName) ->
      return removeFromLocalStorage(createVarName moduleName, varName) if _isLocalStorageAvailable()
      return removeFromCookie createVarName moduleName, varName

    # исключительно для тестирования и отладки
    getKeys: ()->
      objToReturn =
        localStorage: getKeysFromLocalStorage()
        sessionStorage: getKeysFromLocalStorage true
        cookies: getKeysFromCookies()

  return window.inn.storage
