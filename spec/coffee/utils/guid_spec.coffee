describe 'guid module', ->
  describe 'generating uniq id', ->
    guid = null
    beforeEach ->
      console.log 'wait'
      guid = null
      require ['utils/guid'], (guidModule) ->
        console.log "guid", guidModule
        guid = guidModule

    it 'should not generate two or more same ids', ->
      waitsFor ->
        guid isnt null
      runs ->
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