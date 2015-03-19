describe "[StorageFactory module]", ->

  storageFactory = null
  storageFake = null
  storageLocalStorage = null
  storageCookie = null

  beforeEach ->
    require [
      "utils/storage/storageFactory",
      "utils/storage/fakeStorage",
      "utils/storage/localStorage",
      "utils/storage/cookieStorage"
    ],
    (storageFactoryModule, storageFakeModule, storageLocalStorageModule, storageCookieModule) ->
      storageFactory = storageFactoryModule
      storageFake = storageFakeModule
      storageLocalStorage = storageLocalStorageModule
      storageCookie = storageCookieModule

    waitsFor ->
      storageFactory isnt null

  describe "Get storage by type", ->
    it "should returns fake storage", ->
      storage = storageFactory.getStorage(['fake'])
      expect(storage).toBeObject()
      expect(_.isEqual(storage, storageFake)).toBe(true)

    it "should returns local storage", ->
      storage = storageFactory.getStorage(['localStorage'])
      expect(storage).toBeObject()
      expect(_.isEqual(storage, storageLocalStorage)).toBe(true)

    it "should returns cookie storage", ->
      storage = storageFactory.getStorage(['cookies'])
      expect(storage).toBeObject()
      expect(_.isEqual(storage, storageCookie)).toBe(true)
      
  describe "Get storage from chain", ->
    it "should returns first storage from chain if it avaiable", ->
      storage = storageFactory.getStorage(['cookies', 'localStorage'])
      expect(storage).toBeObject()
      expect(_.isEqual(storage, storageCookie)).toBe(true)

    it "should returns second storage from chain if first is disabled", ->
      storage = storageFactory.getStorage(['unknownStorage', 'fake'])
      expect(storage).toBeObject()
      expect(_.isEqual(storage, storageFake)).toBe(true)
