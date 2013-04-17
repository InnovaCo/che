describe 'guid module', ->
  describe 'generating uniq id', ->
    guid = null
    beforeEach ->
      guid = null
      require ['utils/guid'], (guidModule) ->
        guid = guidModule

      waitsFor ->
        guid isnt null

    it 'should not generate two or more same ids', ->
      id = guid
      isSame = false
      isFinished = false

      iterator = (iterationsCount) ->
        isSame = id is guid() or isSame
        if 0 < iterationsCount
          _.delay iterator, iterationsCount--
        else
          isFinished = true

      iterator(1000)

      waitsFor ->
        isFinished
      runs ->
        expect(isSame).toBe(false)