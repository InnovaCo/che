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
      storage = null
      for type in storageType
        storage = @getStorageByType(type)
        break if storage and storage.instance
      if not storage
        console.warn "Can not initialize storage"
      else
        storage

    getStorageByType: (type) ->
      switch type
        when "localStorage" then localStorage
        when "cookies" then cookieStorage
        else false
      
  return returnObj