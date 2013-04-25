#### *module* cookieStorage
#
#
#---
# Модуль для хранения временных данных в cookies
#
define ["utils/storage/abstract"], (Storage) ->

  class CookieStorage extends Storage

    #
    # A complete cookies reader/writer framework with full unicode support.
    # Использованы куски кода вот отсюда:
    # https://developer.mozilla.org/en-US/docs/DOM/document.cookie
    @get = (varName) ->
      return null if not varName or not @hasItemInCookie(varName)
      unescape document.cookie.replace(new RegExp("(?:^|.*;\\s*)" + escape(varName).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*((?:[^;](?!;))*[^;]?).*"), "$1")

    @save = (varName, value, isSessionOnly) ->
      return false if not varName or /^(?:expires|max\-age|path|domain|secure)$/i.test(varName)
      path = "/"
      expires = "; expires=Tue, 19 Jan 2038 03:14:07 GMT" if not isSessionOnly
      document.cookie = "#{escape(varName)}=#{escape(value)};path=#{path}" + expires

    @remove = (varName) ->
      return  if not varName or not @hasItemInCookie(varName)
      document.cookie = escape(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + ((if sPath then "; path=" + sPath else ""))

    @getKeys = ->
      keys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/)
      objToReturn = {}
      for index in [0..keys.length]
        objToReturn[keys(index)] = unescape getFromCookie keys(index)

      objToReturn

    @hasItemInCookie: (sKey) ->
      (new RegExp("(?:^|;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test document.cookie


  return new CookieStorage()