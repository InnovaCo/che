describe "utils/params module", ->
  params = null
  beforeEach ->
    require ["utils/params"], (paramsModule) ->
      params = paramsModule

  describe "encoding objects", ->
    it "should encode object to params string", ->
      waitsFor ->
        params?
      runs ->
        testObject = 
          foo: "bar"
          fooBar: "foo bar"
          bar:
            foo: "bar"
            zoo:
              leo: "cat"

        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat"

        expect(params testObject).toBe expectParams

    it "should encode object to params string, invoke all functions inside it and place returned value", ->
      waitsFor ->
        params?
      runs ->
        testObject = 
          foo: ->
            "bar"
          fooBar: "foo bar"
          bar:
            foo: "bar"
            zoo: ->
              leo: "cat"

        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat"

        expect(params testObject).toBe expectParams

  describe "work with another data", ->
    it "should return same string if it received as parameter", ->
      waitsFor ->
        params?
      runs ->
        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat"

        expect(params expectParams).toBe expectParams

    it "should invoke function if it was received as parameter", -> 
      waitsFor ->
        params?
      runs ->
        testFunc = -> 
          foo: ->
            "bar"
          fooBar: "foo bar"
          bar:
            foo: "bar"
            zoo: ->
              leo: "cat"

        expectParams = "foo=bar&fooBar=foo%2520bar&bar%5Bfoo%5D=bar&bar%5Bzoo%5D%5Bleo%5D=cat"

        expect(params testFunc).toBe expectParams


