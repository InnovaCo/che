# Story: Custom log

describe "[Log module]", ->
  logger = null

  beforeEach ->
    logger = null
    require ["utils/log"], (logModule) ->
      logger = logModule

    waitsFor ->
      logger isnt null

  afterEach ->
    logger.empty()

  ###### Narrative
  # *As* an any other module
  # *I want* to log my activity
  # *So that* I can use give API
  describe "Module interface", ->
    describe "should contain methods", ->
    it "'log', 'notice','info', 'warn', and 'error'", ->
      expect(logger.log).toBeFunction()
      expect(logger.notice).toBeFunction()
      expect(logger.info).toBeFunction()
      expect(logger.warn).toBeFunction()
      expect(logger.error).toBeFunction()

    it "'getEntries', 'printEntries', 'getMaxEntries','empty', 'saveToServer','sendStat'", ->
      expect(logger.getEntries).toBeFunction()
      expect(logger.printEntries).toBeFunction()
      expect(logger.getMaxEntries).toBeFunction()
      expect(logger.empty).toBeFunction()
      expect(logger.saveToServer).toBeFunction()
      expect(logger.sendStat).toBeFunction()

    describe '.getEntries()', ->
      it 'should return empty array if there was no any log action', ->
        expect( logger.getEntries() ).toBeArray()
        expect( logger.getEntries() ).toBeEmpty()

      it 'should return array with entries objects if there was log action', ->
        logger.log 'Some log'
        expect(logger.getEntries()).toBeArray()
        expect(logger.getEntries().length).toEqual 1

    describe '.getMaxEntries()', ->
      it 'should return integer for maximum stack size', ->
        expect(logger.getMaxEntries()).toBeGreaterThan 0

  describe 'Log', ->
    ## +Title: Clean up the memory
    # In order to keep low memory usage
    # As a clever developer :)
    # I want to have some ways to manage it
    #
    # +Scenario1: manual cleaning memory
    # Given logModule,
    # When requests the .empty()
    # Then log internal entries list should become empty
    #
    # +Scenario2: automatically clean up the memory
    # Given logModule,
    # And internal log entries list more then 1000 entries
    # When append new entry
    # Then log internal entries should pop out first 100 entries
    # And only append new entry
    describe 'when calling .log()', ->
      it "should append entry to internal entries list", ->
        logger.log 'Some log'
        expect(logger.getEntries().length).toEqual 1

      it 'and this entry must contain entry object {"time": ..., "type": "log", "ns": ..., "message": ...}', ->
        logger.log 'Some log'
        someEntry = logger.getEntries()[0]
        expect(someEntry.type).toBe 'log'
        expect(someEntry.message).toBe 'Some log'


    ####### Narrative
    # *As* a support-man
    # *I want* to have ability to save logs somewhere
    # *So that* I can analyse them at any time even if browser was restarted
    ###
      describe 'Saving logs', ->
        describe 'when uselocalStorage option enabled', ->
          # +Scenario1: there's no browser support for LocalStorage
          # Given LogModule
          #   And option useLocalStorage
          #  When append log entry
          #  Then it must not throw error (?!)
          #   And prepend (unshift) with error entry about not supporting of LocalStorage
          describe "if there's not browser support of LocalStorage", ->
            oldLocalStorage = null
            beforeEach ->
              oldLocalStorage = window.localStorage
              window.localStorage = 1

            afterEach ->
              # window.localStorage = oldLocalStorage
              # oldLocalStorage = null

            it "should'nt throw error ", ->
              expect( () -> logger.log("Some log") ).not.toThrow()

            it "should prepend entries list with error entry about unavailable LocalStorage object", ->

          describe "if there is browser support of LocalStorage", ->
            it "should save entry to localStorage", ->
            it "should clean localStorage if there is more then one "
      ###

    describe 'Clean up the memory', ->
      ## +Title: Clean up the memory
      # In order to keep low memory usage
      # As a clever developer :)
      # I want to have some ways to manage it
      #
      # +Scenario1: manual cleaning memory
      # Given logModule,
      # When requests the .empty()
      # Then log internal entries list should become empty
      #
      # +Scenario2: Internal clean up the memory
      # Given logModule,
      # And internal log entries list more then 1000 entries
      # When append new entry
      # Then log internal entries should shift out first 100 entries
      # And only append new entry
      describe 'Log internal entries list', ->
        it "should become empty when .empty() called", ->
          logger.log 'Some log'
          logger.log 'Some more log'
          expect(logger.getEntries().length).toEqual 2

          logger.empty()
          expect(logger.getEntries().length).toEqual 0

        it "should keep internal log entries list on maxsize when maxsize entries level reached and want to append a new one", ->
          maxEntries = logger.getMaxEntries()
          logger.log "Some entries #{num}" for num in [1..maxEntries]
          expect( logger.getEntries().length ).toEqual maxEntries

          logger.log 'A new one entry'
          expect( logger.getEntries().length ).toEqual maxEntries


        it "should remove very first item from entries list when maxsize entries level reached and want to append a new one", ->
          veryFirstItem = null
          newFirstItem = null
          maxEntries = logger.getMaxEntries()
          logger.log "Some entries #{num}" for num in [1..maxEntries]
          veryFirstItem = logger.getEntries()[0]
          newFirstItem = logger.getEntries()[1]

          logger.log 'A new one entry'
          expect( logger.getEntries() ).toContain newFirstItem
          expect( logger.getEntries() ).not.toContain veryFirstItem
          expect( logger.getEntries()[0] ).toBe newFirstItem

