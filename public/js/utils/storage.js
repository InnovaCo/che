(function() {

  define([], function() {
    var createVarName, getFromCookie, getFromLocalStorage, getKeysFromCookies, getKeysFromLocalStorage, isLocalStorageAvailable, removeFromCookie, removeFromLocalStorage, returnObj, saveToCookie, saveToLocalStorage, _localStorage, _sessionStorage;
    _localStorage = window.localStorage;
    _sessionStorage = window.sessionStorage;
    getFromLocalStorage = function(varName) {
      var _ref;
      return (_ref = _localStorage.getItem(varName)) != null ? _ref : _sessionStorage.getItem(varName);
    };
    saveToLocalStorage = function(varName, value, isSessionOnly) {
      var _storage;
      _storage = isSessionOnly ? _sessionStorage : _localStorage;
      removeFromLocalStorage(varName);
      try {
        _storage.setItem(varName, value);
        return true;
      } catch (err) {
        return false;
      }
    };
    removeFromLocalStorage = function(varName) {
      _localStorage.removeItem(varName);
      _sessionStorage.removeItem(varName);
      return true;
    };
    getKeysFromLocalStorage = function(isSessionOnly) {
      var item, objToReturn, _i, _ref, _storage;
      _storage = isSessionOnly ? _sessionStorage : _localStorage;
      objToReturn = {};
      for (item = _i = 0, _ref = _storage.length; 0 <= _ref ? _i <= _ref : _i >= _ref; item = 0 <= _ref ? ++_i : --_i) {
        objToReturn[_storage.key(item)] = _storage.get(_storage.key(item));
      }
      return objToReturn;
    };
    getFromCookie = function(varName) {
      if (!varName || !hasItemInCookie(varName)) {
        return null;
      }
      return unescape(document.cookie.replace(new RegExp("(?:^|.*;\\s*)" + escape(varName).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*((?:[^;](?!;))*[^;]?).*"), "$1"));
    };
    saveToCookie = function(varName, value, isSessionOnly) {
      var expires, path;
      if (!varName || /^(?:expires|max\-age|path|domain|secure)$/i.test(varName)) {
        return false;
      }
      path = "/";
      if (!isSessionOnly) {
        expires = "; expires=Tue, 19 Jan 2038 03:14:07 GMT";
      }
      return document.cookie = ("" + (escape(varName)) + "=" + (escape(value)) + ";path=" + path) + expires;
    };
    removeFromCookie = function(varName) {
      if (!varName || !hasItemInCookie(varName)) {
        return;
      }
      return document.cookie = escape(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + (sPath ? "; path=" + sPath : "");
    };
    ({
      hasItemInCookie: function(sKey) {
        return (new RegExp("(?:^|;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie);
      }
    });
    isLocalStorageAvailable = function() {
      return typeof _localStorage !== "undefined";
    };
    createVarName = function(moduleName, varName) {
      return "" + moduleName + "/" + varName;
    };
    ({
      removeItem: function(sKey, sPath) {}
    });
    getKeysFromCookies = function() {
      var index, keys, objToReturn, _i, _ref;
      keys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/);
      objToReturn = {};
      for (index = _i = 0, _ref = keys.length; 0 <= _ref ? _i <= _ref : _i >= _ref; index = 0 <= _ref ? ++_i : --_i) {
        objToReturn[keys(index)] = unescape(getFromCookie(keys(index)));
      }
      return objToReturn;
    };
    returnObj = {
      save: function(moduleName, varName, value, isSessionOnly, isStorageOnly) {
        var key;
        value = JSON.stringify(value);
        key = createVarName(moduleName, varName);
        if (isLocalStorageAvailable()) {
          return saveToLocalStorage(key, value, isSessionOnly);
        }
        if (isStorageOnly) {
          return false;
        }
        return saveToCookie(key, value, isSessionOnly);
      },
      get: function(moduleName, varName) {
        var key, value;
        key = createVarName(moduleName, varName);
        value = isLocalStorageAvailable() ? getFromLocalStorage(key, varName) : getFromCookie(key, varName);
        return JSON.parse(value);
      },
      remove: function(moduleName, varName) {
        if (isLocalStorageAvailable()) {
          return removeFromLocalStorage(createVarName(moduleName, varName));
        }
        return removeFromCookie(createVarName(moduleName, varName));
      },
      getKeys: function() {
        var objToReturn;
        return objToReturn = {
          localStorage: getKeysFromLocalStorage(),
          sessionStorage: getKeysFromLocalStorage(true),
          cookies: getKeysFromCookies()
        };
      }
    };
    return returnObj;
  });

}).call(this);
