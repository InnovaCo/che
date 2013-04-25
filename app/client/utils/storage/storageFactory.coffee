#### storageFactory
#
#
#---
# Фабрика, инициализирующая необходимый модуль для работы с хранилищем
# Доступные типы хранилищ:
# "localStorage" - хранит данные в localStorage & sessionStorage
# "cookies" - хранит данные в cookies
#
define ["utils/storage/localStorage", "utils/storage/cookieStorage"], (localStorage, cookieStorage) ->

  returnObj =
    getStorage: (storageType) ->
      switch storageType
        when "localStorage" then localStorage
        when "cookies" then cookieStorage
        else
          console.warn "Unknown storage type: " + storageType
          return localStorage
      
  return returnObj