# storage tests
mockups = 
  localStorage = 
    store:      {}
    setItem:    (moduleName, key, value) ->
      @store["#{moduleName}/#{key}"] = value
      on
    getItem:    (moduleName, key) ->
      @store["#{moduleName}/#{key}"]
    removeItem: (moduleName, key) ->
      @store["#{moduleName}/#{key}"] = null
    getKeys: () ->
      return @store

describe "[Storage module]", ->
  describe "Module interface", ->
    storage = null

    beforeEach ->
      storage = null
      require ["utils/storage"], (storageModule) ->
        storage = storageModule

    it "should contain 'save', 'get', 'remove' and 'getKeys' functions", ->
      waitsFor ->
        storage isnt null
      runs ->
        expect(storage.save).toBeFunction()
        expect(storage.get).toBeFunction()
        expect(storage.remove).toBeFunction()
        expect(storage.getKeys).toBeFunction()

  describe "Saving key/value", ->
    storage = null
    _oldLocalStorage = null
    _oldSessionStorage = null
    _oldCookie = null
    beforeEach ->
      storage = null

      # remember originally state
      _oldLocalStorage = window.localStorage
      _oldSessionStorage = window.sessionStorage
      #_oldCookie = document.cookie
      require ["utils/storage"], (storageModule) ->
        storage = storageModule

    afterEach ->
      # return originally values
      window.localStorage = _oldLocalStorage
      window.sessionStorage = _oldSessionStorage
      window.localStorage.removeItem("testModule/testKey")
      window.sessionStorage.removeItem("testModule/testKey")
      #document.cookie = _oldCookie


    it "should save given key/value pair (both must be strings) with 'moduleName'-prefix to localStorage only (4-th parameter is false). If possible. ", ->
      waitsFor ->
        storage isnt null
      runs ->
        # MockUp object
        if typeof window.localStorage is "undefined"
          window.localStorage = mockups.localStorage

        storage.save("testModule", "testKey", "testValue")
        expect(JSON.parse window.localStorage.getItem "testModule/testKey").toBe "testValue"
        expect(JSON.parse window.sessionStorage.getItem "testModule/testKey").toBe null

    it "should save given key/value pair (both must be strings) with 'moduleName'-prefix to sessionStorage only (4-th parameter is true). If possible.", ->
      waitsFor ->
        storage isnt null
      runs ->
        # MockUp object
        if typeof window.localStorage is "undefined"
          window.localStorage = mockups.localStorage
        if typeof window.localStorage is "undefined"
          window.localStorage = mockups.localStorage

        storage.save("testModule", "testKey", "testValue", true)
        expect(JSON.parse window.sessionStorage.getItem "testModule/testKey").toBe "testValue"
        expect(JSON.parse window.localStorage.getItem "testModule/testKey").toBe null


    it "should'nt save to anywhere given key/value pair with 'moduleName'-prefix if 'value' isn't string (?)", ->
      waitsFor ->
        storage isnt null
      runs ->
        _oldLocalStorage = window.localStorage
        if typeof window.localStorage is "undefined"
          # MockUp object
          window.localStorage = mockups.localStorage
        storage.save("testModule", "testKey", "testValue")
        expect(JSON.parse window.localStorage.getItem "testModule/testKey").toBe "testValue"

        window.localStorage = _oldLocalStorage


  describe "Getting value", ->
    storage = null
    _oldLocalStorage = null
    _oldSessionStorage = null
    _oldCookie = null
    beforeEach ->
      storage = null

      # remember originally state
      window.localStorage.removeItem("testModule/testKey")
      window.sessionStorage.removeItem("testModule/testKey")
      _oldLocalStorage = window.localStorage
      _oldSessionStorage = window.sessionStorage
      #_oldCookie = document.cookie
      require ["utils/storage"], (storageModule) ->
        storage = storageModule

    afterEach ->
      # return originally values
      window.localStorage = _oldLocalStorage
      window.sessionStorage = _oldSessionStorage
      window.localStorage.removeItem("testModule/testKey")
      window.sessionStorage.removeItem("testModule/testKey")
      #document.cookie = _oldCookie

    it "should get value of previously saved pair", ->
      waitsFor ->
        storage isnt null
      runs ->
        if typeof window.localStorage is "undefined"
          # MockUp object
          window.localStorage = mockups.localStorage
        storage.save("testModule", "testKey", "testValue")
        expect(storage.get("testModule","testKey")).toBe "testValue"

    it "should'nt get value if there is'nt previously saved pair", ->
      waitsFor ->
        storage isnt null
      runs ->
        if typeof window.localStorage is "undefined"
          # MockUp object
          window.localStorage = mockups.localStorage
        expect(storage.get("testModule","testKey")).toBeNull()


