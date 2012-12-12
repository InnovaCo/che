# storage tests
describe "Storage module", ->
  describe "Check interface", ->
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
