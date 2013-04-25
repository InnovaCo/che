#### *module* localStorage
#
#
#---
# Модуль для фейкового режима работы с хранилищем
#
define ["utils/storage/abstract"], (Storage) ->

  class FakeStorage extends Storage

    @get = (varName) ->
      return null

    @save = (varName, value, isSessionOnly) ->
      on

    @remove = (varName) ->
      on

    @getKeys = () ->
      {}

  return new FakeStorage()
