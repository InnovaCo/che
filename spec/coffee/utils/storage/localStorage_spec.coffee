describe "[LocalStorage module]", ->
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

  storage = null

  beforeEach ->
    require ["che!utils/storage/localStorage"], (storageModule) ->
      storage = storageModule

    waitsFor ->
      storage isnt null

  describe "Module interface", ->
    it "should contain 'save', 'get', 'remove' and 'getKeys' functions", ->
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
      # remember originally state
      _oldLocalStorage = window.localStorage
      _oldSessionStorage = window.sessionStorage
      #_oldCookie = document.cookie

    afterEach ->
      # return originally values
      window.localStorage = _oldLocalStorage
      window.sessionStorage = _oldSessionStorage
      window.localStorage.removeItem("testModule/testKey")
      window.sessionStorage.removeItem("testModule/testKey")
      #document.cookie = _oldCookie


    it "should save given key/value pair (both must be strings) with 'moduleName'-prefix to localStorage only (4-th parameter is false). If possible. ", ->
      # MockUp object
      if typeof window.localStorage is "undefined"
        window.localStorage = mockups.localStorage

      storage.save("testModule", "testKey", "testValue")
      expect(JSON.parse window.localStorage.getItem "testModule/testKey").toBe "testValue"
      expect(JSON.parse window.sessionStorage.getItem "testModule/testKey").toBe null

    it "should save given key/value pair (both must be strings) with 'moduleName'-prefix to sessionStorage only (4-th parameter is true). If possible.", ->
      # MockUp object
      if typeof window.localStorage is "undefined"
        window.localStorage = mockups.localStorage
      if typeof window.localStorage is "undefined"
        window.localStorage = mockups.localStorage

      storage.save("testModule", "testKey", "testValue", true)
      expect(JSON.parse window.sessionStorage.getItem "testModule/testKey").toBe "testValue"
      expect(JSON.parse window.localStorage.getItem "testModule/testKey").toBe null


    it "should'nt save to anywhere given key/value pair with 'moduleName'-prefix if 'value' isn't string (?)", ->
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
      # remember originally state
      window.localStorage.removeItem("testModule/testKey")
      window.sessionStorage.removeItem("testModule/testKey")
      _oldLocalStorage = window.localStorage
      _oldSessionStorage = window.sessionStorage
      #_oldCookie = document.cookie

    afterEach ->
      # return originally values
      window.localStorage = _oldLocalStorage
      window.sessionStorage = _oldSessionStorage
      window.localStorage.removeItem("testModule/testKey")
      window.sessionStorage.removeItem("testModule/testKey")
      #document.cookie = _oldCookie

    it "should get value of previously saved pair", ->
      if typeof window.localStorage is "undefined"
        # MockUp object
        window.localStorage = mockups.localStorage
      storage.save("testModule", "testKey", "testValue")
      expect(storage.get("testModule","testKey")).toBe "testValue"

    it "should'nt get value if there is'nt previously saved pair", ->
      if typeof window.localStorage is "undefined"
        # MockUp object
        window.localStorage = mockups.localStorage
      expect(storage.get("testModule","testKey")).toBeNull()


