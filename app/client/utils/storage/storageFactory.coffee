#### storageFactory
#
#
#---
# Фабрика, инициализирующая необходимый модуль для работы с хранилищем
# Доступные типы хранилищ:
#   * "localStorage" - хранит данные в localStorage & sessionStorage
#   * "cookies" - хранит данные в cookies
#   * "fake" - фейковый режим (ничего никуда не сохраняется)
#
define ["utils/storage/localStorage", "utils/storage/cookieStorage", "utils/storage/fakeStorage"], (localStorage, cookieStorage, fakeStorage) ->

  returnObj =
    getStorage: (storageType) ->
      storage = null
      for type in storageType
        storage = @getStorageByType(type)
        break if storage and storage.instance
      if not storage
        console.warn "Can not initialize storage"
        fakeStorage
      else
        storage

    getStorageByType: (type) ->
      switch type
        when "localStorage" then localStorage
        when "cookies" then cookieStorage
        when "fake" then fakeStorage
        else false
      
  return returnObj