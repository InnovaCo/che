describe "preload  module", -> 
    describe "searching for widgets", ->
        preload = null

        beforeEach ->
            preload = require "preload";

        it "should find all widgets on page", ->
            widgets = preload.test.findWidgets
            expect(widgets.toString()).toBe ""

    describe "loading widgets to page", ->
        preload = null
        
        beforeEach ->
            preload = require "preload"

        it "should load all the found widgets", ->
            widgets = preload.test.findWidgets
            is_all_loaded = no
            define [widgets], ->
                is_all_loaded = yes
            waitsFor ->
                is_all_loaded
            runs ->
                #describe expecting modules