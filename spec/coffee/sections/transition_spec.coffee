
# остальные тесты нужно постепенно перетащить из sections_spec.coffee, так как изначально transition был внутри модуля sections

describe 'sections/transition module', ->
  Transition =
  queue = null
  require [
    'sections/transition'
    'sections/asyncQueue'
    ], (transitionModule, queueModule) ->
    Transition = transitionModule
    queue = queueModule

  beforeEach ->
    waitsFor ->
      Transition?

  describe 'creating transitions', ->
    beforeEach ->
      affix "span#one span"

    it 'should create transition and set previous created as .prev_transition', ->
      transition = new Transition({})
      nextTransition = new Transition({}, transition)

      expect(transition).toBe(nextTransition.prev_transition)
      expect(transition.next_transition).toBe(nextTransition)

    it 'should destroy first transition after 10 new created', ->
      firstTransition = new Transition {sections: ""}

      prevTransition = firstTransition
      for i in [1..10]
        transition = new Transition
          index: i
          sections: "<section data-selector='someName: #one'><span>hello #{i}</span></section>",
          prevTransition

        prevTransition = transition

      expect(firstTransition).toBeEmpty()

    it 'should not destroy first transition after 9 new created', ->
      firstTransition = new Transition {sections: ""}

      prevTransition = firstTransition
      for i in [1..9]
        transition = new Transition
          index: i
          sections: "<section data-selector='someName: #one'><span>hello #{i}</span></section>",
          prevTransition

        prevTransition = transition

      expect(firstTransition).not.toBeEmpty()
