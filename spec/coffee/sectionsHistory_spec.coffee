define 'sectionsHistory module', ->
  history = null
  beforeEach ->
    require ['sectionsHistory'], (historyModule) ->
      history = historyModule

  describe 'creating transitions', ->
    it 'should create transition and set firstTransition and currentTransition', ->
      waitsFor ->
        history?
      runs ->
        transition = new history._transition({}, null)
        expect(history._getFirstTransition()).toBe(transition)
        expect(history._getCurrentTransition()).toBe(transition)

    it 'should create transition and set previous created as .prev', ->
      waitsFor ->
        history?
      runs ->
        transition = new history._transition({}, null)
        nextTransition = transition.next
          some: data

        expect(transition).toBe(nextTransition.prev)
        expect(transition.next).toBe(nextTransition)

    it 'should destroy first transition after 10 new created', ->
      firstTransition = new history._transition({}, null)

      transition = firstTransition
      for i in [1...10]
        transition = transition.next {}

      expect(firstTransition).toBeEmpty()



  describe 'invoking transitions', ->
    it 'should replace sections', ->
    it 'should replace sections and undo', ->

  describe 'creating invoke objects', ->