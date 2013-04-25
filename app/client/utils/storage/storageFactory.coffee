#### storageFactory
#
#
#---
# Фабрика, инициализирующая необходимый модуль для работы с хранилищем
# Доступные типы хранилищ:
# "localStorage" - хранит данные в localStorage & sessionStorage
#
define ["utils/storage/localStorage"], (localStorage) ->

  returnObj =
    getStorage: (storageType) ->
      switch storageType
        when "localStorage" then localStorage
        else
          console.warn "Unknown storage type: " + storageType
          return localStorage
      
  return returnObj